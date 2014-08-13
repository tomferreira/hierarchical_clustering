
require_relative 'pre_process_manager'

class DocumentManager

    attr_writer :document_dir, :stopwords_file, :min_support
    attr_writer :f1tree, :f1set, :all_documents

    def initialize
    
    end
    
    def pre_process
        preprocess_manager = PreProcessManager.new @document_dir, @stopwords_file, @min_support
        
        @f1tree, @f1set, @all_documents = preprocess_manager.preprocess
        
        callIDF
    end
    
    def get_all_docs
        @all_documents
    end
    
    def get_f1_sets
        @f1set
    end
    
private

    def callIDF
    
    end

end