
require 'unicode'

class StopWordHandler

    STOPWORDS_FILE = "stop_words.txt"
    
    GRAPHIC_MARKUPS = [ "!", "?", "%", "''", "(", ")", "[", "]", "{", "}", ",", ".", "*", "&", "...", ":", ";", "``", "´", "\xE2\x94\x80", "\xE2\x80\x94", "\xE2\x80\x93", "\xE2\x80\x98", "\xE2\x80\x99", "", "/"]

    def initialize( language )

        stopword_file = File.dirname(__FILE__) +"/#{language}/#{STOPWORDS_FILE}"
        @stopwords = []
        
        load_stopwords(stopword_file)
    end
    
    def remove_stopwords(tokens)

        tokens.each do |token|
            token.strip!
            token.tr!("\xE2\x80\x9C", "") # aspa inglesa abertura
            token.tr!("\xE2\x80\x9D", "") # aspa inglesa fechamento
            token.tr!("\xE2\x80\x98", "") # aspa simples inglesa abertura
            token.tr!("\xE2\x80\x99", "") # aspa simples inglesa abertura
            token.tr!(".*", "")
        end
        
        tokens.delete_if { |token| token =~ /^[0-9]*[:-]?[0-9]+$/ }

        # return words not included in stopwords
        tokens - @stopwords - GRAPHIC_MARKUPS
    end

private

    def load_stopwords(stopword_file)

        File.open(stopword_file, "rb", :encoding => "utf-8").each_line do |line|
            @stopwords << Unicode.downcase(line.chomp)
        end
        
        @stopwords.sort!
    end

end
