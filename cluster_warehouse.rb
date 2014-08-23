
require_relative 'clusters'
require_relative 'cluster'

class ClusterWarehouse

    def initialize
        @clusters = Hash.new
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
        
        itemset_copy = FreqItemset.new        
        freqitemset.freqitems.each { |freqitem| itemset_copy.add_freqitem( freqitem ) }

        while !itemset_copy.freqitems.empty?
        
            # Find the corresponding group of clusters based on the first itemID
            first_item_id = itemset_copy.freqitems.first.freq_item_id
                                    
            target_clusters = @clusters[first_item_id]
            return false if target_clusters.nil?
            
            # Find the clusters that can cover the current frequent itemset in target_clusters
            return false if !target_clusters.find_subset_clusters(itemset_copy, clusters)
            
            itemset_copy.freqitems.shift
        end
    end
    
    # Get the potential children cluster of the given frquent itemset. 
    # The resultant clusters have no specific order.
    def find_potencial_children(freqitemset, clusters)
        return if freqitemset.nil?
        
        clusters.clear
        
        # Find the corresponding group of clusters based on the first itemID
        first_item_id = freqitemset.freqitems.first.freq_item_id
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