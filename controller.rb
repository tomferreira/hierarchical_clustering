﻿
require_relative 'tree_builder'
require_relative 'document_manager'
require_relative 'freqitem_manager'
require_relative 'evaluation_manager'

class Controller

    STOPWORDS_FILENAME = 'stop_words.txt'

    def initialize
        @tree_buider = TreeBuilder.new( nil )
        @evaluation_manager = EvaluationManager.new
        
        @document_manager = DocumentManager.new

        @freqitem_manager = FreqItemManager.new
    end    
    
    def run( global_support, cluster_support, k_clusters, input_dir )
    
        @document_manager.document_dir = input_dir
        @document_manager.stopwords_file = STOPWORDS_FILENAME
        @document_manager.min_global_support = global_support
        
        @document_manager.pre_process
        
        documents = @document_manager.all_documents
        f1 = @document_manager.f1sets
                
        puts "********"
        puts "* FIHC *"
        puts "********"

        # Frequent Item Manager mines the frequent itemset (Apriori)    
        @freqitem_manager.min_global_support = global_support
        return false unless @freqitem_manager.mine_global_freqitemsets(documents, f1)
    
        global_freqitemsets = @freqitem_manager.global_freqitemsets

        # Cluster Manager builds the clusters of documents    
        # tree based clustering
        return false unless @cluster_manager.make_clusters(documents, global_freqitemsets, cluster_support)

        # Tree Builder constructs the topical tree
   
        return false unless @tree_builder.build_tree

        # Remove empty clusters
        return false unless @tree_builder.remove_empty_clusters(false)

        # prune children based on inter-cluster similarity with parent
        return false unless @tree_builder.prune_children

        # inter-cluster similarity based pruning
        return false unless @tree_builder.inter_sim_prune(k_clusters)

        # score based pruning
        return false unless @tree_builder.inter_sim_over_prune(k_clusters)

    end

end
