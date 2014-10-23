
require 'parallel'

require 'tree_builder'
require 'document_manager'
require 'freqitem_manager'
require 'cluster_manager'
require 'evaluation_manager'
require 'xml_output_manager'
require 'vina_output_manager'

class Controller

    def initialize(global_support, cluster_support, k_clusters)
        @cluster_support = cluster_support
        @k_clusters = k_clusters

        @cluster_manager = ClusterManager.new       
        @document_manager = DocumentManager.new(global_support)
        @freqitem_manager = FreqItemManager.new(global_support)
        
        @tree_builder = TreeBuilder.new( @cluster_manager )
        @evaluation_manager = EvaluationManager.new
        @output_manager = XmlOutputManager.new("results")
    end

    def output_manager(output_manager)
        @output_manager = output_manager
    end
    
    def run(input_dir, unrefined_docs)

        @document_manager.pre_process(unrefined_docs)
        
        documents = @document_manager.all_documents
        f1 = @document_manager.f1sets
                
        puts "********"
        puts "* FIHC *"
        puts "********"

        # Frequent Item Manager mines the frequent itemset (Apriori)
        @freqitem_manager.mine_global_freqitemsets(documents, f1)
    
        global_freqitemsets = @freqitem_manager.global_freq_itemsets
                
        puts "Global frequent itemsets"
        global_freqitemsets.each { |freqitemset| freqitemset.print2 }

        # Cluster Manager builds the clusters of documents    
        # tree based clustering
        @cluster_manager.make_clusters(documents, global_freqitemsets, @cluster_support)

        # Tree Builder constructs the topical tree   
        @tree_builder.build_tree

        # Remove empty clusters
        @tree_builder.remove_empty_clusters(false)

        # prune children based on inter-cluster similarity with parent
        @tree_builder.prune_children

        # inter-cluster similarity based pruning
        @tree_builder.inter_sim_prune(@k_clusters)

        # score based pruning
        @tree_builder.inter_sim_over_prune(@k_clusters)

        @output_manager.produce_output(@document_manager, @cluster_manager)
    end

end
