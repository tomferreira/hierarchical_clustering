
require 'json'
require 'document_language_detector'
require 'unrefined_doc'
require 'treebank_word_tokenizer'
require 'stopword_handler'
require 'stem_handler'

require 'clustering/clustering'
require 'clustering/fihc/controller'

class HierarchicalClustering

    def initialize(input_dir, strategy)
        @unrefined_docs = []

        pre_process(input_dir)

        strategy.run(input_dir, @unrefined_docs)
    end

private

    def pre_process(input_dir)
        raw_documents = load_documents(input_dir)
    
        language_detector = DocumentLanguageDetector.new(raw_documents)
        language = language_detector.detect

        puts "Detected language: #{language}"

        tokenize(raw_documents, language)
    end

    def load_documents(doc_dir)
        raw_documents = []
    
        Dir["#{doc_dir}/*"].each do |file_name|
        
            next if file_name == "." || file_name == ".."
            
            if File.directory?( file_name )
                raw_documents.concat( load_documents( file_name ) ) 
                next
            end

            document = JSON.parse( File.open(file_name, "rb", :encoding => "utf-8").read )

            raw_documents << { 
                :title => document["title"], :content => Unicode.downcase(document["content"]), :link => document["link"] }
        end
        
        raw_documents
    end

    def tokenize(raw_documents, language)
        tokenizer = TreebankWordTokenizer.new
        stopwords_handler = StopWordHandler.new( language )        
        stem_handler = StemHandler.new( language )

        raw_documents.each do |document|
            tokens = tokenizer.tokenize(document[:content])

            words_clean = stopwords_handler.remove_stopwords(tokens)
        
            stem_handler.stem_file(words_clean)
        
            @unrefined_docs << UnrefinedDoc.new(document[:title], document[:link], words_clean)
        end

        nil
    end

end
