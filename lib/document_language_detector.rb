
require 'language_detector'

class DocumentLanguageDetector

    def initialize(documents)
        @language_detector = LanguageDetector.new
        @documents = documents
    end
    
    def detect
        results = detect_language(@documents)
        
        languages = results.compact.inject({}) { |hash, lang| hash.has_key?(lang) ? hash[lang] += 1 : hash[lang] = 1; hash }
        
        return languages.max_by {|lang, value| value}[0]
    end
    
private

    def detect_language(documents)
        Parallel.map(documents) do |document|                   
            next if rand < 0.7

            @language_detector.detect(document[:content])
        end
    end

end