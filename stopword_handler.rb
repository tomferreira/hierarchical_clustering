
class StopWordHandler

    def initialize(stopword_file)
        @stopword_file = stopword_file
        @stopwords = []
        
        create_stopword_array
    end
    
    def remove_stopwords(file)
        words = File.open(file, "rb").read.gsub("; ", " ").split(" ")

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