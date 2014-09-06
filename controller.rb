
require_relative 'tree_builder'
require_relative 'document_manager'
require_relative 'freqitem_manager'
require_relative 'cluster_manager'
require_relative 'evaluation_manager'
require_relative 'output_manager'

class Controller

    def initialize
        @cluster_manager = ClusterManager.new       
        @document_manager = DocumentManager.new
        @freqitem_manager = FreqItemManager.new
        
        @tree_builder = TreeBuilder.new( @cluster_manager )
        @evaluation_manager = EvaluationManager.new
        @output_manager = OutputManager.new( @document_manager, @cluster_manager )
    end    
    
    def run( global_support, cluster_support, k_clusters, input_dir )
    
        @document_manager.document_dir = input_dir
        @document_manager.min_global_support = global_support
        
        @document_manager.pre_process
        
        documents = @document_manager.all_documents
        f1 = @document_manager.f1sets
                
        puts "********"
        puts "* FIHC *"
        puts "********"

        # Frequent Item Manager mines the frequent itemset (Apriori)    
        @freqitem_manager.min_global_support = global_support
        @freqitem_manager.mine_global_freqitemsets(documents, f1)
    
        global_freqitemsets = @freqitem_manager.global_freq_itemsets
                
        puts "Global frequent itemsets"
        global_freqitemsets.each { |freqitemset| freqitemset.print2 }

        # Cluster Manager builds the clusters of documents    
        # tree based clustering
        @cluster_manager.make_clusters(documents, global_freqitemsets, cluster_support)

        # Tree Builder constructs the topical tree   
        @tree_builder.build_tree

        # Remove empty clusters
        @tree_builder.remove_empty_clusters(false)

        # prune children based on inter-cluster similarity with parent
        @tree_builder.prune_children

        # inter-cluster similarity based pruning
        @tree_builder.inter_sim_prune(k_clusters)

        # score based pruning
        @tree_builder.inter_sim_over_prune(k_clusters)

        # Output Manager organizes and displays the results to user
        suffix_input_dir = input_dir.split("/").last
        
        out_file_path = make_out_file_path( ".", suffix_input_dir, global_support, cluster_support, k_clusters )
        
        @output_manager.produce_output( out_file_path )
    end
    
private

    def make_out_file_path( dir, file_name, global_support, cluster_support, k_clusters )
        return "#{dir}/#{file_name}.xml"
    end

end
