
require_relative 'document_language_detector'
require_relative 'treebank_word_tokenizer'
require_relative 'stopword_handler'
require_relative 'stem_handler'
require_relative 'vocabulary_tree'
require_relative 'freqitem_tree'
require_relative 'freqitemset'
require_relative 'freqitem'
require_relative 'unrefined_doc'
require_relative 'doc_vector'
require_relative 'document'

class PreProcessManager

    def initialize(doc_dir, min_global_support)
        
        load_documents(doc_dir)
    
        language_detector = DocumentLanguageDetector.new(@raw_documents)
        @language = language_detector.detect

        puts "Detected language: #{@language}"
        
        @tokenizer = TreebankWordTokenizer.new
        @stopwords_handler = StopWordHandler.new( @language )        
        @stem_handler = StemHandler.new( @language )
        
        @doc_dir = doc_dir
        @min_global_support = min_global_support
    
        @file_sum = 0
        
        @voc_tree = VocalularyTree.new
        @unrefined_docs = Array.new
        
        # id is the ID for m_word in the freqItem tree
        @id = -1
    end

    # Do preprocessing, which includes F1 finding, document vector creating, and F1 search tree creating.
    # It is the only method that external can call to invoke preprocessing 
    def preprocess
        f1tree, f1sets = find_global_freqitem

        docs = Array.new
        create_documents(docs, f1tree)

        [f1tree, f1sets, docs]
    end

private

    def load_documents(doc_dir)
        @raw_documents = []
    
        Dir["#{doc_dir}/*"].each do |file_name|
        
            next if file_name == "." || file_name == ".."
            
            document = JSON.parse( File.open(file_name, "rb", :encoding => "utf-8").read )

            @raw_documents << { 
                :title => document["title"], :content => Unicode.downcase(document["content"]), :link => document["link"] }
        end
        
        @raw_documents
    end

    def find_global_freqitem
    
        start_time = Time.now
        
        puts "Building vocabulary tree"

        construct_voc_btree(@raw_documents)
        
        puts "Finished in #{Time.now - start_time} seg"

        min_times = (@file_sum * @min_global_support).ceil
        
        puts "# of documents: #{@file_sum}, min_sup = #{@min_global_support}, min_times = #{min_times}"
    
        f1tree = FreqItemTree.new
        f1sets = []
    
        mid_order_traverse(@voc_tree.root, min_times, f1tree, f1sets)
        
        puts "@freqitem_count: #{@freqitem_count}"
        
        # TEMP
        #@voc_tree.print( @voc_tree.root )
    
        # cleanup the nodes of the tree to save memory
        ##@voc_tree.cleanup

        [f1tree, f1sets]
    end

    # create vectors for all documents
    def create_documents(docs, f1tree)
        @unrefined_docs.each do |urf_doc|
            create_document(docs, urf_doc, f1tree)
        end
    end

    # create a vector for a given document
    def create_document(docs, urf_doc, f1tree)

        vec = DocVector.new(@freqitem_count, 0)

        urf_doc.words.each do |word|
            index = f1tree.is_node(word)
                    
            # the word is in the freqitem tree
            vec[index] += 1 if index != -1
        end
    
        docs << Document.new(vec, urf_doc.name, urf_doc.link)
    end
    
    # mid-order traverse can guarantee that the resulting frequent items are in alphabetical order
    def mid_order_traverse(node, min_times, f1tree, f1sets)

        if node != nil
            mid_order_traverse(node.left_child, min_times, f1tree, f1sets)
                        
            if node.freq >= min_times
                @id += 1
                f1tree.insert( node.word, @id )
                add_freqitem(f1sets, node.freq, @id)
            end
            
            mid_order_traverse(node.right_child, min_times, f1tree, f1sets)            
        end
        
        @freqitem_count = @id + 1
    end
    
    def add_freqitem(f1sets, freq, id)        
        freqitem = FreqItem.new(id)
        
        freqitemset = FreqItemset.new
        freqitemset.add_freqitem(freqitem)
        freqitemset.global_support = freq.to_f / @file_sum
        
        f1sets << freqitemset
    end

    def construct_voc_btree(documents)
        documents.each do |document|         
            insert_file_words_to_tree(document, @file_sum)

            # number of docs read
            @file_sum +=1
        end
    end
    
    def insert_file_words_to_tree(document, file_id)

        tokens = @tokenizer.tokenize(document[:content])

        words_clean = @stopwords_handler.remove_stopwords(tokens)
        
        @stem_handler.stem_file(words_clean)
        
        @unrefined_docs << UnrefinedDoc.new(document[:title], document[:link], words_clean)
        
        #puts "Insering #{words_clean.length} words in vocabulary..."
        
        words_clean.each do |word|
            @voc_tree.insert(word, file_id)
        end
    end

end
