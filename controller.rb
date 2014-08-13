
require_relative 'tree_builder'
require_relative 'document_manager'
require_relative 'evaluation_manager'

class Controller

    STOPWORDS_FILENAME = 'stop_words.txt'

    def initialize
        @tree_buider = TreeBuilder.new( nil )
        @evaluation_manager = EvaluationManager.new
        
        @document_manager = DocumentManager.new
    end    
    
    def run( global_support, cluster_support, k_clusters, input_dir )
    
        @document_manager.document_dir = input_dir
        @document_manager.stopwords_file = STOPWORDS_FILENAME
        @document_manager.min_support = global_support
        
        @document_manager.pre_process
        
        documents = @document_manager.get_all_docs        
        f1 = @document_manager.get_f1_sets
    
    end

end