# encoding: utf-8

# * A stemmer for the portuguese language written in ruby.
# *
# * It has been ported from the following perl implementation:
# * http://search.cpan.org/src/XERN/Lingua-PT-Stemmer-0.01/lib/Lingua/PT/Stemmer.pm
# * 
# * More information on this algortihm can be found at:
# * http://www.cs.mdx.ac.uk/research/PhDArea/rslp/RSLP.htm
# *
# * If you find any bugs, please contact me at dpr [at] cin.ufpe.br
# *
# * Hope you enjoy it!
# * Davi Pires

# Dar uma olhada em https://github.com/arcoelho01/rslpStemmer/blob/master/steprules.txt

module Stemmer

    class Portuguese

        def initialize
            @rule = {}

            @rule["plural"] = {
                Regexp.new("ns$") => [ 1, "m" ],
                Regexp.new("ões$") => [ 3, "ão" ],
                Regexp.new("ães$") => [ 1, "ão" ],
                Regexp.new("ais$") => [ 1, "al" ],
                Regexp.new("éis$") => [ 2, "el" ],
                Regexp.new("eis$") => [ 2, "el" ],
                Regexp.new("óis$") => [ 2, "ol" ],
                Regexp.new("is$") => [ 2, "il" ],
                Regexp.new("les$") => [ 2, "l" ],
                Regexp.new("res$") => [ 3, "r" ],
                Regexp.new("s$") => [ 2, "" ],
            }

            @rule["femin"] = {
                Regexp.new("ona$") => [ 3, "ão" ],
                Regexp.new("ã$") => [ 2, "ão" ],
                Regexp.new("ora$") => [ 3, "or" ],
                Regexp.new("na$") => [ 4, "no" ],
                Regexp.new("inha$") => [ 3, "inho" ],
                Regexp.new("esa$") => [ 3, "ès" ],
                Regexp.new("osa$") => [ 3, "oso" ],
                Regexp.new("íaca$") => [ 3, "íaco" ],
                Regexp.new("ica$") => [ 3, "ico" ],
                Regexp.new("ada$") => [ 3, "ado" ],
                Regexp.new("ida$") => [ 3, "ido" ],
                Regexp.new("ída$") => [ 3, "ido" ],
                Regexp.new("ima$") => [ 3, "imo" ],
                Regexp.new("iva$") => [ 3, "ivo" ],
                Regexp.new("eira$") => [ 3, "eiro" ],
            }

            @rule["augment"] = {
                Regexp.new("díssimo$") => [ 5, '' ],
                Regexp.new("abilíssimo$") => [ 5,'' ],
                Regexp.new("íssimo$") => [ 3,'' ],
                Regexp.new("ésimo$") => [ 3,'' ],
                Regexp.new("érrimo$") => [ 4,'' ],
                Regexp.new("zinho$") => [ 2,'' ],
                Regexp.new("quinho$") => [ 4, "c" ],
                Regexp.new("uinho$") => [ 4,'' ],
                Regexp.new("adinho$") => [ 3,'' ],
                Regexp.new("inho$") => [ 3,'' ],
                Regexp.new("alhão$") => [ 4,'' ],
                Regexp.new("uça$") => [ 4,'' ],
                Regexp.new("aço$") => [ 4,'' ],
                Regexp.new("adão$") => [ 4,'' ],
                Regexp.new("ázio$") => [ 3,'' ],
                Regexp.new("arraz$") => [ 4,'' ],
                Regexp.new("arra$") => [ 3,'' ],
                Regexp.new("zão$") => [ 2,'' ],
                Regexp.new("ão$") => [ 3,'' ],
            }

            @rule["noun"] = {
                Regexp.new("encialista$") => [ 4, '' ],
                Regexp.new("alista$") => [ 5, '' ],
                Regexp.new("agem$") => [ 3, '' ],
                Regexp.new("iamento$") => [ 4, '' ],
                Regexp.new("amento$") => [ 3, '' ],
                Regexp.new("imento$") => [ 3, '' ],
                Regexp.new("alizado$") => [ 4, '' ],
                Regexp.new("atizado$") => [ 4, '' ],
                Regexp.new("izado$") => [ 5, '' ],
                Regexp.new("ativo$") => [ 4, '' ],
                Regexp.new("tivo$") => [ 4, '' ],
                Regexp.new("ivo$") => [ 4, '' ],
                Regexp.new("ado$") => [ 2, '' ],
                Regexp.new("ido$") => [ 3, '' ],
                Regexp.new("ador$") => [ 3,'' ],
                Regexp.new("edor$") => [ 3, '' ],
                Regexp.new("idor$") => [ 4, '' ],
                Regexp.new("atória$") => [ 5, '' ],
                Regexp.new("or$") => [ 2, '' ],
                Regexp.new("abilidade$") => [ 5,'' ],
                Regexp.new("icionista$") => [ 4, '' ],
                Regexp.new("cionista$") => [ 5, '' ],
                Regexp.new("ional$") => [ 4, '' ],
                Regexp.new("ència$") => [ 3, '' ],
                Regexp.new("ància$") => [ 4, '' ],
                Regexp.new("edouro$") => [ 3, '' ],
                Regexp.new("queiro$") => [ 3, 'c' ],
                Regexp.new("eiro$") => [ 3, '' ],
                Regexp.new("oso$") => [ 3, '' ],
                Regexp.new("alizaç$") => [ 5, '' ],
                Regexp.new("ismo$") => [ 3, '' ],
                Regexp.new("izaç$") => [ 5, '' ],
                Regexp.new("aç$") => [ 3, '' ],
                Regexp.new("iç$") => [ 3, '' ],
                Regexp.new("ário$") => [ 3, '' ],
                Regexp.new("ério$") => [ 6, '' ],
                Regexp.new("ès$") => [ 4, '' ],
                Regexp.new("eza$") => [ 3, '' ],
                Regexp.new("ez$") => [ 4, '' ],
                Regexp.new("esco$") => [ 4, '' ],
                Regexp.new("ante$") => [ 2, '' ],
                Regexp.new("ástico$") => [ 4, '' ],
                Regexp.new("ático$") => [ 3, '' ],
                Regexp.new("ico$") => [ 4, '' ],
                Regexp.new("ividade$") => [ 5, '' ],
                Regexp.new("idade$") => [ 5, '' ],
                Regexp.new("oria$") => [ 4, '' ],
                Regexp.new("encial$") => [ 5, '' ],
                Regexp.new("ista$") => [ 4, '' ],
                Regexp.new("quice$") => [ 4, 'c' ],
                Regexp.new("ice$") => [ 4, '' ],
                Regexp.new("íaco$") => [ 3, '' ],
                Regexp.new("ente$") => [ 4, '' ],
                Regexp.new("inal$") => [ 3, '' ],
                Regexp.new("ano$") => [ 4, '' ],
                Regexp.new("ável$") => [ 2, '' ],
                Regexp.new("ível$") => [ 5, '' ],
                Regexp.new("ura$") => [ 4, '' ],
                Regexp.new("ual$") => [ 3, '' ],
                Regexp.new("ial$") => [ 3, '' ],
                Regexp.new("al$") => [ 4, '' ],
            }

            @rule["verb"] = {
                Regexp.new("aríamo$") => [ 2, ''],
                Regexp.new("eria$") => [ 3, '' ],
                Regexp.new("ássemo$") => [ 2, '' ],
                Regexp.new("ermo$") => [ 3, '' ],
                Regexp.new("eríamo$") => [ 2, '' ],
                Regexp.new("esse$") => [ 3, '' ],
                Regexp.new("èssemo$") => [ 2, '' ],
                Regexp.new("este$") => [ 3, '' ],
                Regexp.new("iríamo$") => [ 3, '' ],
                Regexp.new("íamo$") => [ 3, '' ],
                Regexp.new("íssemo$") => [ 3, '' ],
                Regexp.new("iram$") => [ 3, '' ],
                Regexp.new("áramo$") => [ 2, '' ],
                Regexp.new("íram$") => [ 3, '' ],
                Regexp.new("árei$") => [ 2, '' ],
                Regexp.new("irde$") => [ 2, '' ],
                Regexp.new("aremo$") => [ 2, '' ],
                Regexp.new("irei$") => [ 3, '' ],
                Regexp.new("ariam$") => [ 2, '' ],
                Regexp.new("irem$") => [ 3, '' ],
                Regexp.new("aríei$") => [ 2, '' ],
                Regexp.new("iria$") => [ 3, '' ],
                Regexp.new("ássei$") => [ 2, '' ],
                Regexp.new("irmo$") => [ 3, '' ],
                Regexp.new("assem$") => [ 2, '' ],
                Regexp.new("isse$") => [ 3, '' ],
                Regexp.new("ávamo$") => [ 2, '' ],
                Regexp.new("iste$") => [ 4, '' ],
                Regexp.new("èramo$") => [ 3, '' ],
                Regexp.new("amo$") => [ 2, '' ],
                Regexp.new("eremo$") => [ 3, '' ],
                Regexp.new("ara$") => [ 2, '' ],
                Regexp.new("eriam$") => [ 3, '' ],
                Regexp.new("ará$") => [ 2, '' ],
                Regexp.new("eríei$") => [ 3, '' ],
                Regexp.new("are$") => [ 2, '' ],
                Regexp.new("èssei$") => [ 3, '' ],
                Regexp.new("ava$") => [ 2, '' ],
                Regexp.new("essem$") => [ 3, '' ],
                Regexp.new("emo$") => [ 2, '' ],
                Regexp.new("íramo$") => [ 3, '' ],
                Regexp.new("era$") => [ 3, '' ],
                Regexp.new("iremo$") => [ 3, '' ],
                Regexp.new("erá$") => [ 3, '' ],
                Regexp.new("iriam$") => [ 3, '' ],
                Regexp.new("ere$") => [ 3, '' ],
                Regexp.new("iríei$") => [ 3, '' ],
                Regexp.new("iam$") => [ 3, '' ],
                Regexp.new("íssei$") => [ 3, '' ],
                Regexp.new("íei$") => [ 3, '' ],
                Regexp.new("issem$") => [ 3, '' ],
                Regexp.new("imo$") => [ 3, '' ],
                Regexp.new("ando$") => [ 2, '' ],
                Regexp.new("ira$") => [ 3, '' ],
                Regexp.new("endo$") => [ 3, '' ],
                Regexp.new("irá$") => [ 3, '' ],
                Regexp.new("indo$") => [ 3, '' ],
                Regexp.new("ire$") => [ 3, '' ],
                Regexp.new("ondo$") => [ 3, '' ],
                Regexp.new("omo$") => [ 3, '' ],
                Regexp.new("aram$") => [ 2, '' ],
                Regexp.new("ai$") => [ 2, '' ],
                Regexp.new("arde$") => [ 2, '' ],
                Regexp.new("am$") => [ 2, '' ],
                Regexp.new("arei$") => [ 2, '' ],
                Regexp.new("ear$") => [ 4, '' ],
                Regexp.new("arem$") => [ 2, '' ],
                Regexp.new("ar$") => [ 2, '' ],
                Regexp.new("aria$") => [ 2, '' ],
                Regexp.new("uei$") => [ 3, '' ],
                Regexp.new("armo$") => [ 2, '' ],
                Regexp.new("ei$") => [ 3, '' ],
                Regexp.new("asse$") => [ 2, '' ],
                Regexp.new("em$") => [ 2, '' ],
                Regexp.new("aste$") => [ 2, '' ],
                Regexp.new("er$") => [ 2, '' ],
                Regexp.new("avam$") => [ 2, '' ],
                Regexp.new("eu$") => [ 3, '' ],
                Regexp.new("ávei$") => [ 2, '' ],
                Regexp.new("ia$") => [ 3, '' ],
                Regexp.new("eram$") => [ 3, '' ],
                Regexp.new("ir$") => [ 3, '' ],
                Regexp.new("erde$") => [ 3, '' ],
                Regexp.new("iu$") => [ 3, '' ],
                Regexp.new("erei$") => [ 3, '' ],
                Regexp.new("ou$") => [ 3, '' ],
                Regexp.new("èrei$") => [ 3, '' ],
                Regexp.new("i$") => [ 3, '' ],
                Regexp.new("erem$") => [ 3, '' ],
            }

            @rule["adverb"] = {
                Regexp.new("mente$") => [0, '']
            }

            @rule["vowel"] = {
                Regexp.new("[aeo]$") => [3, '']
            }

            @rule["accent"] = {
                Regexp.new("[äâàáã]") => [0, 'a'],
                Regexp.new("[êéèë]") => [0, 'e'],
                Regexp.new("[ïîìí]") => [0, 'i'],
                Regexp.new("[üúùû]") => [0, 'u'],
                Regexp.new("[ôöóòõ]") => [0, 'o'],
                Regexp.new("[ç]") => [0, 'c']
            }
        end

        def stem(term)
            apply_rule("plural", term) if term =~ /s$/
            apply_rule("femin", term) if term =~ /a$/
            apply_rule("augment", term)
            apply_rule("adverb", term)
            apply_rule("noun", term)
            apply_rule("verb", term)
            apply_rule("vowel", term)  
            apply_rule("accent", term)

            return term
        end

        private

        def apply_rule(rule_id, term)
            rule_to_apply = @rule[rule_id]

            rule_to_apply.each_pair do |re, operation| 
                term.gsub!(re, operation[1]) if term =~ re && term.gsub(re, "").length > operation[0] 
            end

            return term
        end

    end

end
