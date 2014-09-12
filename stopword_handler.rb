
class StopWordHandler

    STOPWORDS_FILE = "stop_words.txt"

    def initialize( language )

        @stopword_file = "#{language}/#{STOPWORDS_FILE}"
        @stopwords = []
        
        create_stopword_array
    end
    
    def remove_stopwords(file)
        body = File.open(file, "rb").read.force_encoding("utf-8").downcase

        body.tr!(".,;:_*\"?!()[]{}0123456789", "")
        body.tr!("\xC2\xBA", "")
        body.tr!("\xC2\xB0", "")
        body.tr!("\xC2\xAA", "")
        body.tr!("\xE2\x80\x9C", "")
        body.tr!("\xE2\x80\x9D", "")

        words = body.split(" ")

        # return words not included in stopwords
        words - @stopwords
    end

private

    def create_stopword_array

        File.open(@stopword_file, "rb") do |file|
            while (line = file.gets)
                @stopwords << line.chomp
            end
        end

    end

end
