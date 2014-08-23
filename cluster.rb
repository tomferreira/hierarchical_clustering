
require_relative 'cluster_freqitemset'
require_relative 'cluster_freqitem'
require_relative 'documents'

class Cluster

    UNTOUCHED = 0
    
    attr_reader :core_items, :num_core_items, :frequencies, :freqitems

    def initialize(freqitemset)
    
        @core_items = ClusterFreqItemset.new
    
        @tree_parent = nil
        
        freqitemset.freqitems.each do |coreitem|
            # TODO
            @core_items.add_freqitem(ClusterFreqItem.new(coreitem.freq_item_id, 0.0))
        end
        
        # the global support of this core itemset
        @core_items.global_support = freqitemset.global_support

        # Cache the number of core items (for efficiency)
        # This is unlikley to change within lifetime of this instance.
        # However, if core items are updated, remember to update this counter.
        @num_core_items = @core_items.freqitems.length
        @status = UNTOUCHED
        
        @documents = Documents.new
        
        @frequencies = DocVector.new
        @occurences = DocVector.new
        
        @freqitemset = ClusterFreqItemset.new
    end
    
    # Get the itemID of the first core item
    def first_core_item_id
        @core_items.freqitems.first.freq_item_id
    end
    
    def add_document(document)
        return if document.nil? || document.doc_vector.nil?
        
        # update the frequencies in this cluster
        update_frequencies(document.doc_vector)
        
        # update the occurences in this cluster
        update_occurences(document.doc_vector)
        
        @documents << document
    end
    
    def num_documents
        @documents.length
    end
    
    # Calculate frequent one itemsets for this cluster based on the given domain
    # frequencies and threshold.  In case the cluster is empty, pDomainFrequencies
    # will be an array of zeros, so this function has no effect.
    def calculate_freq_one_itemsets(domain_frequencies, num_docs, cluster_threshold)
        return if num_docs == 0
        
        @freqitemset.freqitems.clear
        
        min_num_docs = (num_docs * cluster_threshold).ceil
        
        domain_frequencies.each_with_index do |domain_frequencie, i|
            
            next if domain_frequencie < min_num_docs
            
            freqitem = @core_items.freqitems[i]
            
            if freqitem
                # this item is a core item
                raise "i: #{i} | domain_frequencie: #{domain_frequencie} | num_docs: #{num_docs}" if domain_frequencie != num_docs
                freqitem.cluster_support = 1.0
            else
                # add to frequent itemset            
                cluster_support = domain_frequencie / num_docs.to_f

                raise 'error' if cluster_support < 0 || cluster_support > 1
                
                @freqitemset.add_freqitem(ClusterFreqItem.new(i, cluster_support))                
            end
        end        
    end
    
private
    
    # Update the # of documents in this cluster contains this frequen item (for computing frequent 1-itemsets)
    def update_frequencies(doc_vector)

        # Setup the frequencies array
        @frequencies = DocVector.new(doc_vector.length, 0) if @frequencies.length == 0

        present_items = doc_vector.get_present_items(false)
        
        present_items.freqitems.each do |freqitem|
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
    
end