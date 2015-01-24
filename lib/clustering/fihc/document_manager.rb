
require 'clustering/fihc/pre_process_manager'

module Clustering::Fihc
    class DocumentManager

        attr_writer :f1tree
        attr_accessor :f1sets, :all_documents

        def initialize(global_support)
            @min_global_support = global_support
        end    

        def pre_process(unrefined_docs)
            preprocess_manager = PreProcessManager.new(unrefined_docs, @min_global_support)

            @f1tree, @f1sets, @all_documents = preprocess_manager.pre_process

            return false unless call_idf

            return false unless set_freq_one_itemsets

            if Configuration.debug
                puts "Frequent one itemsets:" 
                puts @f1tree.print2( @f1tree.root )
            end
        end

        def get_freq_term_from_id(id)
            @f1tree.value_to_word(id)
        end

    private

        def call_idf
            return true if @all_documents.length <= 0

            # get dimensions
            num_dimensions = @all_documents[0].doc_vector.length

            idf = Array.new(num_dimensions, 0.0)

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
                doc.doc_vector.convert_to_idf!(idf)
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
end