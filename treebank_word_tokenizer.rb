# https://github.com/nltk/nltk/blob/6aa83c7dcb537ea37731c265ab92f7e6c308a944/nltk/tokenize/treebank.py

class TreebankWordTokenizer

    # List of contractions adapted from Robert MacIntyre's tokenizer.
    CONTRACTIONS2 = [
        Regexp.new("(?i)\b(can)(not)\b"),
        Regexp.new("(?i)\b(d)('ye)\b"),
        Regexp.new("(?i)\b(gim)(me)\b"),
        Regexp.new("(?i)\b(gon)(na)\b"),
        Regexp.new("(?i)\b(got)(ta)\b"),
        Regexp.new("(?i)\b(lem)(me)\b"),
        Regexp.new("(?i)\b(mor)('n)\b"),
        Regexp.new("(?i)\b(wan)(na) ")]

    CONTRACTIONS3 = [
        Regexp.new("(?i) ('t)(is)\b"),
        Regexp.new("(?i) ('t)(was)\b")]
        
    def tokenize(text)

        # starting quotes
        text = text.gsub(/^\"/, '``')
        text = text.gsub(/(``)/, ' \1 ')
        text = text.gsub(/([ (\[{<])"/, '\1 `` ')
        
        # punctuation
        text = text.gsub(/([:,])([^\d])/, ' \1 \2')
        text = text.gsub(/\.\.\./, ' ... ')
        text = text.gsub(/[;@#$%&]/, ' \0 ')
        text = text.gsub(/([^\.])(\.)([\]\)}>"\']*)\s*$/, '\1 \2\3 ')
        text = text.gsub(/[?!]/, ' \0 ')
        text = text.gsub(/([^'])' /, "\1 ' ")
        
        # parens, brackets, etc.
        text = text.gsub(/[\]\[\(\)\{\}\<\>]/, ' \0 ')
        text = text.gsub(/--/, ' -- ')
        
        # add extra space to make things easier
        text = " " + text + " "
        
        # ending quotes
        text = text.gsub(/"/, " '' ")
        text = text.gsub(/(\S)(\'\')/, '\1 \2 ')
        text = text.gsub(/([^' ])('[sS]|'[mM]|'[dD]|') /, "\1 \2 ")
        text = text.gsub(/([^' ])('ll|'LL|'re|'RE|'ve|'VE|n't|N'T) /, "\1 \2 ")
    
        CONTRACTIONS2.each do |regexp|
            text = text.gsub(regexp, ' \1 \2 ')
        end
    
        CONTRACTIONS3.each do |regexp|
            text = text.gsub(regexp, ' \1 \2 ')
        end

        return text.split
    end

end