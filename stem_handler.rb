
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
    end

    def stem_file(words)
        words.each do |word|
            word = @stemmer.stem(word)
        end
    end
    
private

    def stem_word(word)
    
        @k = word.length-1
        @k0 = 0
        @j = 0
        
        return if @k <= @k0+1
    
        step1ab( word )
    end
    
    def step1ab( word )
        
        if word[@k] == 's'
            if ends(word, "sses", 4)
                @k -= 2
            elsif ends(word, "ies", 3)
                setto("i", 1)
            elsif word[@k-1] != 's'
                @k -= 1
            end
        end

        if ends(word, "eed", 3)
            @k -= 1 if m(word) > 0
        elsif ( ends(word, "ed", 2) || ends(word, "ing", 3) ) && vowelinstem(word)
            @k = @j
            
            if ends(word, "at", 2)
                setto("ate", 3)
            elsif ends(word, "bl", 2)
                setto("ble", 3)
            elsif ends(word, "iz", 2)
                setto("ize", 3)
            elsif doublecons(word, @k)
                @k -= 1                
                @k += 1 if word[@k] == 'l' || word[@k] == 's' || word[@k] == 'z'                
            elsif m() == 1 && cvc(@k)
                setto("e", 1)
            end
        end
    
    end
    
    def ends(word, s, len)
    
        # tiny speed-up
        return false if s[len-1] != word[@k]
        return false if len > @k-@k0+1
        
        puts "word: #{word} s: #{s} @k: #{@k} i: #{@k-len} j: #{len}"

        return false if word[@k-len..len] != s
        
        @j = @k-len        
        return true
    end
    
    # Measures the number of consonant sequences between k0 and j
    def m(word)
        n = 0
        i = @k0

        while true
            return n if i > @j            
            break unless cons(word, i)
            i += 1        
        end
        
        i += 1
        
        while true        
            while true
                return n if i > j                
                break if cons(word, i)
                i += 1
            end
            
            i += 1
            n += 1
            
            while true
                return n if i > j
                break unless cons(word, i)
                i += 1
            end

            i += 1
        end
    end
    
    def cons(word, i)
    
        case word[i]
        when 'a', 'e', 'i', 'o', 'u'
            return false
        when 'y'
            return ( i == @k0 ? true : !cons(word, i-1) )
        else
            return true
        end
    end
    
    def doublecons(word, i)
        return false if i < @k0+1
        return false if word[i] != word[i-1]
        return cons(word, i)
    end
    
    # cvc(i) is TRUE iif i-2,i-1,i has the form consonant - vowel - consonant
    # and also if the second c is not w,x or y. this is used when trying to
    # restore an e at the end of a short word. e.g.
    #
    #    cav(e), lov(e), hop(e), crim(e), but
    #    snow, box, tray.    
    def cvc(word, i)
        return false if i < @k0+2 || !cons(word, i) || cons(word, i-1) || !cons(word, i-2)
        
        return false if word[i] == 'w' || word[i] == 'z' || word[i] == 'y'
        
        return true        
    end
    
    
    def vowelinstem(word)
        (@k0..j).each{ |i| return true unless cons(word, i) }    
        return false
    end

end
