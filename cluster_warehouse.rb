
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