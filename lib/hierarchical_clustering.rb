
require 'json'
require 'configuration'
require 'document_language_detector'
require 'unrefined_doc'
require 'treebank_word_tokenizer'
require 'stopword_handler'
require 'stem_handler'
require 'performance_monitor'

require 'clustering/clustering'
require 'clustering/fihc/controller'

class HierarchicalClustering

    def initialize(dir: nil, algorithm: nil, debug: false)
        @input_dir = dir
        @algorithm = algorithm
        @unrefined_docs = []

        Configuration.debug = debug

        PerformanceMonitor.restart
    end

    def run(monitor: false)
        PerformanceMonitor.enable = monitor

        pre_process

        PerformanceMonitor.start(:clustering)
        @algorithm.run(@input_dir, @unrefined_docs)
        PerformanceMonitor.stop(:clustering)

        PerformanceMonitor.results
    end

private

    def pre_process
        raw_documents = load_documents(@input_dir)
    
        PerformanceMonitor.start(:language_detector)

        language_detector = DocumentLanguageDetector.new(raw_documents)
        language = language_detector.detect

        PerformanceMonitor.stop(:language_detector)

        puts "Detected language: #{language}" if Configuration.debug

        tokenizer = TreebankWordTokenizer.new

        stopwords_handler = StopWordHandler.new( language )

        stem_handler = StemHandler.new( language )

        # 
        tokens_total = []
        words_clean_total = []
        words_stem_total = []

        raw_documents.each do |document|

            PerformanceMonitor.start(:tokenize)
            tokens = tokenizer.tokenize(document[:content])
            PerformanceMonitor.stop(:tokenize)

            tokens_total += Marshal.load(Marshal.dump(tokens))

            PerformanceMonitor.start(:cleaning)
            words_clean = stopwords_handler.remove_stopwords(tokens)
            PerformanceMonitor.stop(:cleaning)

            words_clean_total += Marshal.load(Marshal.dump(words_clean))
        
            PerformanceMonitor.start(:stemming)
            stem_handler.stem_file!(words_clean)
            PerformanceMonitor.stop(:stemming)

            words_stem_total += Marshal.load(Marshal.dump(words_clean))
        
            @unrefined_docs << UnrefinedDoc.new(document[:title], document[:link], words_clean)

        end

        PerformanceMonitor.add(:tokens_uniq, tokens_total.uniq.count)
        PerformanceMonitor.add(:tokens_total, tokens_total.count)
        
        PerformanceMonitor.add(:words_clean_uniq, words_clean_total.uniq.count)
        PerformanceMonitor.add(:words_clean_total, words_clean_total.count)

        PerformanceMonitor.add(:words_stem_uniq, words_stem_total.uniq.count)
        PerformanceMonitor.add(:words_stem_total, words_stem_total.count)
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
                :title => document["title"], :content => Unicode.downcase(document["content"]), :link => document["link"] 
            }
        end
        
        raw_documents
    end

end
