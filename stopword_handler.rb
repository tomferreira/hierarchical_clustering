
class StopWordHandler

    def initialize(stopword_file)
        @stopword_file = stopword_file
        @stopwords = []
        
        create_stopword_array
    end
    
    def remove_stopwords(file)
        #puts "Removing stopwords from #{file}"
               
        words = File.open(file, "rb").read.split(" ")

        # return words not included in stopwords
        words - @stopwords 
    end
    
private

    def create_stopword_array
    
        File.open(@stopword_file, "rb") do |infile|
            while (line = infile.gets)
                @stopwords << line.chomp
            end
        end
        
        #puts "Stopwords: #{@stopwords}"    
    end

end