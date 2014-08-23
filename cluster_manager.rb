
require_relative 'cluster_warehouse'

class ClusterManager

    def initialize
        @cluster_warehouse = ClusterWarehouse.new
    end

    def make_clusters(documents, global_freqitemsets, cluster_support)
        return false if documents.nil? || global_freqitemsets.nil? || global_freqitemsets.empty?
        
        @documents = documents
        @cluster_support = cluster_support
        
        puts "*** Adding clusters to warehouse"
        return false unless @cluster_warehouse.add_clusters(global_freqitemsets)
        
        puts "#{global_freqitemsets.length} clusters are constructed"
        
        puts "*** Constructing initial clusters"

        # Assign documents to cluster (initial clustering)
        construct_initial_clusters
        
        puts "*** Computing frequent one itemsets for initial clusters"

        # Compute the frequent 1-itemsets for each cluster
        # Maintain the cluster support for each frequent item in the cluster
        compute_freq_one_itemsets(false, cluster_support)
        
        # Clear all the documents in all the clusters in the Warehouse
        return false unless remove_all_documents
        
        puts "*** Constructing clusters based on scores"
        return false unless construct_score_clusters
        
        # Recompute the frequent 1-itemests for each cluster
        puts "*** Computing frequent one itemsets for clusters"
        compute_freq_one_itemsets(true, cluster_support)
        
        return true
    end
    
private
    
    def construct_initial_clusters
        puts "@documents: #{@documents.length}"

        @documents.each do |document|
            # get the appeared items in the document
            present_freq_items = document.doc_vector.get_present_items(true)
            
            covered_clusters = Clusters.new
            # get all clusters that can cover this doc
            @cluster_warehouse.find_covered_clusters(present_freq_items, covered_clusters)
            
            # assign doc to all the covered clusters
            assign_doc_to_clusters(document, covered_clusters)
        end
    end
    
    # Assign the document to the given clusters.
    def assign_doc_to_clusters(document, clusters)    
        clusters.each do |cluster|
            cluster.add_document(document)
        end
    end
    
    # Compute the frequent 1-itemsets for each cluster.
    # If include_potencial_children == TRUE, then include all its potential children;
    # otherwise, compute the frequent 1-itemset for each cluster individually.
    def compute_freq_one_itemsets(include_potencial_children, cluster_support)
    
        all_clusters = @cluster_warehouse.all_clusters
        
        puts "all_clusters: #{all_clusters.length}"
        
        all_clusters.each_with_index do |cluster, j|
            frequencies = cluster.frequencies            
            
            domain_frequencies = DocVector.new
            domain_frequencies.concat(frequencies)
            
            # number of documents in this cluster and its children
            num_docs = cluster.num_documents

            compute_potential_children_frequencies(cluster.core_items, domain_frequencies, num_docs) if include_potencial_children
            
            puts "cluster #{j}: #{cluster}"
            
            # compute the frequent 1-itemsets for this cluster based on this domain frequencies
            cluster.calculate_freq_one_itemsets(domain_frequencies, num_docs, cluster_support)
        end
    end
    
    # Compute the potential children frequencies
    # input: resultFrequencies should contain the parent node frequencies
    # input: numDocs should contains number of documents in the parent node
    # output: resultFrequencies will contain the result of adding up all frequencies 
    # from all potential children AND the parent.
    # output: numDocs will contain the total number documents in parent and children
    def compute_potential_children_frequencies(core_items, domain_frequencies, num_docs)
    
        children_clusters = Clusters.new
    
        # get all the children clusters
        @cluster_warehouse.find_potencial_children(core_items, children_clusters)
        
        # add up all frequencies in these children
        add_up_cluster_frequencies(children_clusters, domain_frequencies, num_docs)
    end

end