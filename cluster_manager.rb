
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
        return false unless construct_initial_clusters
        
        puts "*** Computing frequent one itemsets for initial clusters"

        # Compute the frequent 1-itemsets for each cluster
        # Maintain the cluster support for each frequent item in the cluster
        return false unless compute_freq_one_itemsets(false, cluster_support)
        
        # Clear all the documents in all the clusters in the Warehouse
        return false unless remove_all_documents
        
        puts "*** Constructing clusters based on scores"
        return false unless construct_score_clusters
        
        # Recompute the frequent 1-itemests for each cluster
        puts "*** Computing frequent one itemsets for clusters"
        return false unless compute_freq_one_itemsets(true, cluster_support)
        
        return true
    end

end