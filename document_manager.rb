
require_relative 'pre_process_manager'
require_relative 'kmvector'

class DocumentManager

    attr_writer :stopwords_file, :document_dir, :min_global_support
    attr_writer :f1tree
    attr_accessor :f1sets, :all_documents
    
    def pre_process
        preprocess_manager = PreProcessManager.new(@stopwords_file, @document_dir, @min_global_support)
        
        @f1tree, @f1sets, @all_documents = preprocess_manager.preprocess
                
        return false unless call_idf

        return false unless set_freq_one_itemsets
        
        puts "Frequent one itemsets:\n"
        puts @f1tree.print2( @f1tree.root )
    end
    
private

    def call_idf
        return true if @all_documents.length <= 0
    
        # get dimensions
        num_dimensions = @all_documents[0].doc_vector.length

        idf = KMVector.new
        ##idf.size = num_dimensions

        (0...num_dimensions).each { |i| idf[i] = 0.0 }

        # calculate term frequencies
        @all_documents.each do |doc|
            doc_vector = doc.doc_vector

            (0...num_dimensions).each do |t|
                idf[t] += 1 if doc_vector[t] > 0
            end
        end

        # calculate IDF
        log2 = Math.log10(2)
        log_ndocs = Math.log10(@all_documents.length) / log2

        (0...num_dimensions).each do |t|
            idf[t] = log_ndocs - Math.log10(idf[t] + 1) / log2;
        end
        
        # convert the doc vector to IDF vector
        @all_documents.each do |doc|
            return false unless doc.doc_vector.convert_to_idf!(idf)
        end

        true
    end

    # Set frequent 1-itemsets to each doc vector
    def set_freq_one_itemsets
        @all_documents.each do |doc|
            doc.doc_vector.freq_one_itemsets = @f1sets
        end
        
        true
    end

end
