
require_relative 'cluster_freqitemset'
require_relative 'cluster_freqitem'

class Cluster

    UNTOUCHED = 0
    
    attr_reader :core_items, :num_core_items, :documents, :frequencies, :occurences, :freqitems, :tree_parent, :tree_children

    def initialize(freqitemset = nil)
    
        unless freqitemset.nil?

            @core_items = ClusterFreqItemset.new
            @tree_parent = nil

            freqitemset.each do |coreitem|
                @core_items.add_freqitem(ClusterFreqItem.new(coreitem.freq_item_id, 0.0))
            end

            # the global support of this core itemset
            @core_items.global_support = freqitemset.global_support

            # Cache the number of core items (for efficiency)
            # This is unlikley to change within lifetime of this instance.
            # However, if core items are updated, remember to update this counter.
            @num_core_items = @core_items.length

        else
            @self_score = 0.0
        end
        
        @tree_children = Clusters.new
        
        @status = UNTOUCHED
        
        @documents = Array.new
        
        @frequencies = DocVector.new
        @occurences = DocVector.new
        
        @freqitems = ClusterFreqItemset.new
    end
    
    def label( document_manager )
        @core_items.map { |freqitem| document_manager.get_freq_term_from_id( freqitem.freq_item_id ) }
    end
    
    # Get the itemID of the first core item
    def first_core_item_id
        @core_items.first.freq_item_id
    end
    
    def add_document(document)
        return if document.nil? || document.doc_vector.nil?
        
        doc_vector = document.doc_vector
        
        # update the frequencies in this cluster
        update_frequencies(doc_vector)
        
        # update the occurences in this cluster
        update_occurences(doc_vector)
        
        @documents << document
    end
    
    def num_documents
        @documents.length
    end
    
    # Get total number of documents including its tree children
    def num_documents_include_tree_children
        num_documents_include_tree_children_rec( self )
    end
    
    # Get total number of clusters including its tree children
    def num_clusters_include_tree_children
        num_clusters_include_tree_children_rec( self )
    end
    
    # Calculate frequent one itemsets for this cluster based on the given domain
    # frequencies and threshold.  In case the cluster is empty, pDomainFrequencies
    # will be an array of zeros, so this function has no effect.
    def calculate_freq_one_itemsets(domain_frequencies, num_docs, cluster_threshold)
        # TODO: Será que realmente é aqui, ou depois do return?
        @freqitems.clear
        
        return if num_docs == 0
        
        min_num_docs = (num_docs * cluster_threshold).ceil
        
        # for performance
        i = 0

        domain_frequencies.each do |domain_frequencie|
            
            if domain_frequencie < min_num_docs
                i += 1
                next
            end
            
            freqitem = @core_items.get_freqitem(i)
            
            if freqitem
                # this item is a core item
                raise "error" if domain_frequencie != num_docs

                freqitem.cluster_support = 1.0
            else
                # add to frequent itemset
                cluster_support = domain_frequencie.to_f / num_docs

                raise 'error' if cluster_support < 0 || cluster_support > 1
                
                @freqitems.add_freqitem(ClusterFreqItem.new(i, cluster_support))
            end
            
            i += 1
        end
    end
    
    # Add up the children frequencies with the frequency in this cluster
    # output: resultFrequencies will contain the result of adding up all frequencies 
    # from all tree children AND the parent.
    def compute_tree_children_frequencies(result_frequencies)
        result_frequencies.add_up(@frequencies)
        
        @tree_children.each do |child_cluster|
            child_cluster.compute_tree_children_frequencies(result_frequencies)
        end
    end
    
    # Add up the children occurences with the occurences in this cluster
    # output: resultOccurences will contain the result of adding up all occurences 
    # from all tree children AND the parent.
    def compute_tree_children_occurences(result_occurences)
        result_occurences.add_up(@occurences)
        
        @tree_children.each do |child_cluster|
            child_cluster.compute_tree_children_occurences(result_occurences)
        end
    end
    
    def add_tree_child(cluster)
        @tree_children.add_cluster(cluster)
    end
    
    def set_tree_parent(cluster)
        @tree_parent = cluster
    end
    
    def clear_tree_parent
        @tree_parent = nil
    end
    
    # Merge the given cluster to this cluster with its children
    def merge_cluster(cluster, all_clusters)
        children = cluster.tree_children
        
        children.each do |child|
            add_tree_child(child)
            child.set_tree_parent(self)
        end
        
        cluster.tree_children.clear
        
        # move documents to this cluster
        cluster.documents.each do |doc|
            add_document(doc)
        end
        
        # remove the cluster from its parent
        parent = cluster.tree_parent
        parent.tree_children.delete( cluster )
        
        cluster.clear_tree_parent
        
        # remove from the given list
        all_clusters.delete( cluster ) if all_clusters
    end
    
    # Move all documents in the given cluster and its children to this cluster
    def merge_cluster_prune_children(cluster, all_clusters)
        
        # move documents to this cluster        
        cluster.documents.each do |document|
            add_document(document)
        end
        
        # move children's documents to this cluster
        children = cluster.tree_children
        
        children.each do |child|
            merge_cluster_prune_children(child, all_clusters)
        end
        
        children.clear
        cluster.clear_tree_parent
        
        # remove from the given list
        all_clusters.delete(cluster) if all_clusters
    end
    
    # Remove all documents in this cluster
    def remove_all_documents
        @documents.clear
        
        # setup frequencies
        @frequencies = DocVector.new(@frequencies.length, 0)
        
        # setup occurences
        @occurences = DocVector.new(@occurences.length, 0)
    end
    
private
    
    # Update the # of documents in this cluster contains this frequen item (for computing frequent 1-itemsets)
    def update_frequencies(doc_vector)

        # Setup the frequencies array
        @frequencies = DocVector.new(doc_vector.length, 0) if @frequencies.length == 0

        present_items = doc_vector.get_present_items(false)
        
        present_items.each do |freqitem|
            # For each present item, update the frequencies by one.
            # Even though an item appears 10 times in a doc, it is counted as 1.
            @frequencies[freqitem.freq_item_id] += 1
        end
    end
    
    # Update the # of occurences of this frequent item in this cluster
    def update_occurences(doc_vector)
        # Setup the occurences array
        @occurences = DocVector.new(doc_vector.length, 0) if @occurences.length == 0
        
        @occurences.add_up(doc_vector)
    end
    
    # Get total number of documents including its tree children
    def num_documents_include_tree_children_rec(parent_cluster)    
        num_total = parent_cluster.num_documents
        
        parent_cluster.tree_children.each do |child|
            num_total += child.num_documents_include_tree_children
        end
        
        return num_total
    end
    
    def num_clusters_include_tree_children_rec(parent_cluster)
        num_total = parent_cluster.tree_children.length
        
        parent_cluster.tree_children.each do |child|
            num_total += child.num_clusters_include_tree_children
        end
        
        return num_total
    end    
end