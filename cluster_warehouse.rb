
require_relative 'clusters'
require_relative 'cluster'

class ClusterWarehouse

    attr_reader :tree_root

    def initialize
        @clusters = Hash.new
        
        @tree_root = Cluster.new
    end

    # Add a collection of clusters to the warehouse based on the given frequent itemsets.
    def add_clusters(freqitemsets)
        freqitemsets.each do |freqitemset|
            add_cluster(freqitemset)
        end
        
        return true
    end
    
    # Get the clusters that can cover the given frequent itemset.
    # The resultant clusters have no specific order.
    # Note: mainly used for document assginment stage.
    def find_covered_clusters(freqitemset, clusters)
        return if freqitemset.nil?
        
        # make a shallow copy
        itemset_copy = FreqItemset.new        
        freqitemset.each { |freqitem| itemset_copy.add_freqitem( freqitem ) }

        while !itemset_copy.empty?
        
            # Find the corresponding group of clusters based on the first itemID
            first_item_id = itemset_copy.first.freq_item_id
                                    
            target_clusters = @clusters[first_item_id]
            raise 'error' if target_clusters.nil?
            
            # Find the clusters that can cover the current frequent itemset in target_clusters
            raise 'error' if !target_clusters.find_subset_clusters(itemset_copy, clusters)
            
            itemset_copy.shift
        end
    end
    
    # Get the potential parent cluster of the given frequent itemset.
    # The resultant pClusters have no specific order.
    # Note: mainly used for the tree construction stage.
    def find_potential_parents(include_great_grand_parents, freqitemset, clusters)
        # find all ancestors
        find_covered_clusters(freqitemset, clusters)
        
        if include_great_grand_parents
            clusters.remove_larger_than_k_itemsets(freqitemset.length - 1)
        else
            # filter out the grandparents or great... grandparents, keep the parents        
            clusters.retain_k_itemsets(freqitemset.length - 1)
        end
    end
    
    # Get the potential children cluster of the given frquent itemset. 
    # The resultant clusters have no specific order.
    def find_potencial_children(freqitemset, clusters)
        return if freqitemset.nil?
        
        clusters.clear
        
        # Find the corresponding group of clusters based on the first itemID
        first_item_id = freqitemset.first.freq_item_id
        target_clusters = @clusters[first_item_id]
        
        target_clusters.find_superset_clusters(freqitemset, clusters)
    end
    
    def all_clusters
        all_clusters = Clusters.new
        
        @clusters.each do |id, clusters|
            all_clusters.add_clusters(clusters)
        end
        
        return all_clusters
    end
    
    def all_clusters_reverse_order
        all_clusters.reverse
    end
    
    def clear_dangling_documnents
        @tree_root.remove_all_documents
    end
    
    # Get the global support of the given frequent item
    def get_frequent_item_global_support(item_id)
        clusters = @clusters[item_id]        
        raise 'error' if clusters.nil? || clusters.empty?
        
        cluster = clusters[0]
        
        # error in warehouse construction phase
        raise 'error' if cluster.first_core_item_id != item_id
        
        return cluster.core_items.global_support
    end
    
private

    # Add a cluster to the warehouse.
    def add_cluster(freqitemset)
    
        # Make a new cluster
        new_cluster = Cluster.new(freqitemset)
        
        # Find the appropriate place for this new cluster in the map
        first_core_id = new_cluster.first_core_item_id
        
        dest_clusters = @clusters[first_core_id]
        
        if dest_clusters.nil?        
            dest_clusters = Clusters.new            
            @clusters[first_core_id] = dest_clusters
        end
        
        # Add the new cluster to this collection
        dest_clusters.add_cluster(new_cluster)
    end

end