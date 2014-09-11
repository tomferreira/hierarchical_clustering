
require 'language_detector'

class DocumentLanguageDetector

    def initialize(doc_dir)
        @language_detector = LanguageDetector.new
        @doc_dir = doc_dir
    end
    
    def detect
        results = detect_language(@doc_dir).flatten
        
        languages = results.inject({}) { |hash, lang| hash.has_key?(lang) ? hash[lang] += 1 : hash[lang] = 1; hash }
        
        return languages.max_by {|lang, value| value}[0]
    end
    
private

    def detect_language(doc_dir)        
        Parallel.map(Dir["#{doc_dir}/*"]) do |file_name| 
        
            next if file_name == "." || file_name == ".."
            
            return detect_language(File.expand_path(file_name)) if File.directory?( file_name )

            @language_detector.detect(File.open(file_name, "rb").read)
        end
    end

end