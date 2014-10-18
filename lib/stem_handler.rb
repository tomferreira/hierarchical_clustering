
require_relative 'en/stemmer'
require_relative 'pt/stemmer'

class StemHandler

    class LanguageNotImplemented; end

    def initialize( language )
        case language
        when 'en'
            @stemmer = Stemmer::English.new
        when 'pt'
            @stemmer = Stemmer::Portuguese.new
        else
            raise LanguageNotImplemented.new
        end

        @buffer = {}
    end

    def stem_file(words)
        words.map do |word|
            unless @buffer.has_key?(word)
                @buffer[word] = @stemmer.stem(word)
            else
                @buffer[word]
            end
        end
    end

end
