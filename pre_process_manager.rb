
require_relative 'stem_handler'
require_relative 'words_btree'
require_relative 'unrefined_docs'
require_relative 'doc_vector'
require_relative 'documents'

class PreProcessManager

    def initialize(stopwords_filename, doc_dir, min_global_support)

	    @doc_dir = doc_dir
	    @min_global_support = min_global_support
	
	    @word_sum = 0
	    @file_sum = 0
	
	    @stem_handler = StemHandler.new
	    @voc_tree = WordsBTree.new
	    @unrefined_docs = UnrefinedDocs.new

    end

    # Do preprocessing, which includes F1 finding, document vector creating, and F1 search tree creating.
    # It is the only method that external can call to invoke preprocessing 
    def preprocess
        f1tree, f1sets = find_global_freqitem

        docs = Documents.new
        create_documents(docs, f1tree)

        [f1tree, f1sets, docs]
    end

private

    def find_global_freqitem

	    #char * pDir = m_docDir.GetBuffer(m_docDir.GetLength());
	    @file_sum = construct_voc_btree(@doc_dir)

        puts @file_sum
        puts @min_global_support

	    min_times = (@file_sum * @min_global_support).ceil

        puts "# of documents: #{@file_sum}, min_sup = #{@min_global_support}"
	
	    f1tree, f1sets = mid_order_traverse(@voc_tree.root, min_times);
	
        # cleanup the nodes of the tree to save memory
	    ##@voc_tree.cleanup

        [f1tree, f1sets]
    end

    # create vectors for all documents
    def create_documents(docs, f1tree)
	    @unrefined_docs.each do |urf_doc|
            create_document(docs, urf_doc, f1tree);		
	    end
    end

    # create a vector for a given document
    def create_document(docs, urf_doc, f1tree)

	    vec = DocVector.new
	    vec.SetSize(@freqitem_count, -1)
	
	    urf_doc.words.each do |word|
		    index = f1tree.is_node(word)
		
            # the word is in the freqItem Tree
		    vec[index] += 1 if index != -1
	    end
	
	    docs << Document.new(*vec, urf_doc.name)
    end
    
    def mid_order_traverse(node, min_times)
        [0, 0]
    end

    def construct_voc_btree(start_dir)
        0
    end

end
