
# * A stemmer for the portuguese language written in ruby.
# *
# * It has been ported from the following perl implementation:
# * http://search.cpan.org/src/XERN/Lingua-PT-Stemmer-0.01/lib/Lingua/PT/Stemmer.pm
# Dar uma olhada em https://github.com/arcoelho01/rslpStemmer/blob/master/steprules.txt

module Stemmer

    class Portuguese

        def initialize
            @rule = {}

            @rule[:plural] = {
                Regexp.new("ns$") => [ 1, "m" ],
                Regexp.new("ões$") => [ 2, "ão" ],
                Regexp.new("ães$") => [ 1, "ão", ["mães"] ],
                Regexp.new("ais$") => [ 1, "al", ["cais","mais"] ],
                Regexp.new("éis$") => [ 2, "el" ],
                Regexp.new("eis$") => [ 2, "el" ],
                Regexp.new("óis$") => [ 2, "ol" ],
                Regexp.new("is$") => [ 2, "il", ["lápis","cais","mais","crúcis","biquínis","pois","depois","dois","leis"] ],
                Regexp.new("les$") => [ 2, "l" ],
                Regexp.new("res$") => [ 3, "r" ],
                Regexp.new("s$") => [ 2, "", ["aliás","pires","lápis","cais","mais","mas","menos","férias","fezes","pêsames","crúcis","gás", "atrás","moisés","através","convés","ês","país","após","ambas","ambos","messias"] ],
            }

            @rule[:femin] = {
                Regexp.new("ona$") => [ 3, "ão", ["abandona","lona","iona","cortisona","monótona","maratona","acetona","detona","carona"] ],
                Regexp.new("ã$") => [ 2, "ão", ["amanhã","arapuã","fã","divã"] ],
                Regexp.new("ora$") => [ 3, "or" ],
                Regexp.new("na$") => [ 4, "no", ["carona","abandona","lona","iona","cortisona","monótona","maratona","acetona","detona","guiana","campana","grana","caravana","banana","paisana"] ],
                Regexp.new("inha$") => [ 3, "inho", ["rainha","linha","minha"] ],
                Regexp.new("esa$") => [ 3, "ês", ["mesa","obesa","princesa","turquesa","ilesa","pesa","presa"] ],
                Regexp.new("osa$") => [ 3, "oso", ["mucosa","prosa"] ],
                Regexp.new("íaca$") => [ 3, "íaco" ],
                Regexp.new("ica$") => [ 3, "ico", ["dica"] ],
                Regexp.new("ada$") => [ 3, "ado", ["pitada"] ],
                Regexp.new("ida$") => [ 3, "ido", ["vida"] ],
                Regexp.new("ída$") => [ 3, "ido", ["recaída","saída","dúvida"] ],
                Regexp.new("ima$") => [ 3, "imo", ["vítima"] ],
                Regexp.new("iva$") => [ 3, "ivo", ["saliva","oliva"] ],
                Regexp.new("eira$") => [ 3, "eiro", ["beira","cadeira","frigideira","bandeira","feira","capoeira","barreira","fronteira","besteira","poeira"] ],
            }

            @rule[:augment] = {
                Regexp.new("díssimo$") => [ 5, '' ],
                Regexp.new("abilíssimo$") => [ 5, '' ],
                Regexp.new("íssimo$") => [ 3, '' ],
                Regexp.new("ésimo$") => [ 3, '' ],
                Regexp.new("érrimo$") => [ 4, '' ],
                Regexp.new("zinho$") => [ 2, '' ],
                Regexp.new("quinho$") => [ 4, "c" ],
                Regexp.new("uinho$") => [ 4, '' ],
                Regexp.new("adinho$") => [ 3, '' ],
                Regexp.new("inho$") => [ 3, '', ["caminho","cominho"] ],
                Regexp.new("alhão$") => [ 4, '' ],
                Regexp.new("uça$") => [ 4, '' ],
                Regexp.new("aço$") => [ 4, '', ["antebraço"] ],
                Regexp.new("adão$") => [ 4, '' ],
                Regexp.new("ázio$") => [ 3, '', ["topázio"] ],
                Regexp.new("arraz$") => [ 4, '' ],
                Regexp.new("arra$") => [ 3, '' ],
                Regexp.new("zão$") => [ 2, '', ["coalizão"] ],
                Regexp.new("ão$") => [ 3, '', ["lição","camarão","chimarrão","canção","coração","embrião","grotão","glutão","ficção","fogão","feição","furacão","gamão","lampião","leão","macacão","nação","órfão","orgão","patrão","portão","quinhão","rincão","tração","falcão","espião","mamão","folião","cordão","aptidão","campeão","colchão","limão","leilão","melão","barão","milhão","bilhão","fusão","cristão","ilusão","capitão","estação","senão"] ],
            }

            @rule[:noun] = {
                Regexp.new("encialista$") => [ 4, '' ],
                Regexp.new("alista$") => [ 5, '' ],
                Regexp.new("agem$") => [ 3, '', ["coragem","chantagem","vantagem","carruagem"] ],
                Regexp.new("iamento$") => [ 4, '' ],
                Regexp.new("amento$") => [ 3, '', ["firmamento","fundamento","departamento"] ],
                Regexp.new("imento$") => [ 3, '' ],
                
                #{"mento$",6,"",{"firmamento","elemento","complemento","instrumento","departamento"}},
                
                Regexp.new("alizado$") => [ 4, '' ],
                Regexp.new("atizado$") => [ 4, '' ],                
                Regexp.new("izado$") => [ 5, '', ["organizado","pulverizado"] ],
                Regexp.new("ativo$") => [ 4, '', ["pejorativo","relativo"] ],
                Regexp.new("tivo$") => [ 4, '', ["relativo"] ],
                Regexp.new("ivo$") => [ 4, '', ["passivo","possessivo","pejorativo","positivo"] ],
                Regexp.new("ado$") => [ 2, '', ["grado"] ],
                Regexp.new("ido$") => [ 3, '', ["cândido","consolido","rápido","decido","tímido","duvido","marido"] ],
                Regexp.new("ador$") => [ 3,'' ],
                Regexp.new("edor$") => [ 3, '' ],
                Regexp.new("idor$") => [ 4, '', ["ouvidor"] ],
                Regexp.new("atória$") => [ 5, '' ],
                
                #{"tor",3,"",{"benfeitor","leitor","editor","pastor","produtor","promotor","consultor"}},
                
                Regexp.new("or$") => [ 2, '', ["motor","melhor","redor","rigor","sensor","tambor","tumor","assessor","benfeitor","pastor","terior","favor","autor"] ],
                Regexp.new("abilidade$") => [ 5,'' ],
                Regexp.new("icionista$") => [ 4, '' ],
                Regexp.new("cionista$") => [ 5, '' ],
                Regexp.new("ional$") => [ 4, '' ],
                Regexp.new("ência$") => [ 3, '' ],
                Regexp.new("ância$") => [ 4, '', ["ambulância"] ],
                Regexp.new("edouro$") => [ 3, '' ],
                Regexp.new("queiro$") => [ 3, 'c' ],
                Regexp.new("eiro$") => [ 3, '', ["desfiladeiro","pioneiro","mosteiro"] ],
                Regexp.new("oso$") => [ 3, '', ["precioso"] ],
                Regexp.new("alizaç$") => [ 5, '' ],
                Regexp.new("ismo$") => [ 3, '' ],
                Regexp.new("izaç$") => [ 5, '' ],
                Regexp.new("aç$") => [ 3, '' ],
                Regexp.new("iç$") => [ 3, '' ],
                Regexp.new("ário$") => [ 3, '', ["voluntário","salário","aniversário","diário","lionário","armário"] ],
                
                #{"atório",3}
                #{"rio",5,"",{"voluntário","salário","aniversário","diário","compulsório","lionário","próprio","stério","armário"}},
                
                Regexp.new("ério$") => [ 6, '' ],
                Regexp.new("ês$") => [ 4, '' ],
                Regexp.new("eza$") => [ 3, '' ],
                Regexp.new("ez$") => [ 4, '' ],
                Regexp.new("esco$") => [ 4, '' ],
                Regexp.new("ante$") => [ 2, '', ["gigante","elefante","adiante","possante","instante","restaurante"] ],
                Regexp.new("ástico$") => [ 4, '', ["eclesiástico"] ],
                Regexp.new("ático$") => [ 3, '' ],
                
                #{"tico",3,"",{"político","eclesiástico","diagnostico","prático","doméstico","diagnóstico","idêntico","alopático","artístico","autêntico","eclético","crítico","critico"}},
                
                Regexp.new("ico$") => [ 4, '', ["tico","público","explico"] ],                
                Regexp.new("ividade$") => [ 5, '' ],
                Regexp.new("idade$") => [ 5, '', ["autoridade","comunidade"] ],
                Regexp.new("oria$") => [ 4, '', ["categoria"] ],
                Regexp.new("encial$") => [ 5, '' ],
                Regexp.new("ista$") => [ 4, '' ],
                Regexp.new("quice$") => [ 4, 'c' ],
                Regexp.new("ice$") => [ 4, '', ["cúmplice"] ],
                Regexp.new("íaco$") => [ 3, '' ],
                Regexp.new("ente$") => [ 4, '', ["freqüente","alimente","acrescente","permanente","oriente","aparente"] ],
                Regexp.new("inal$") => [ 3, '' ],
                Regexp.new("ano$") => [ 4, '' ],
                Regexp.new("ável$") => [ 2, '', ["afável","razoável","potável","vulnerável"] ],
                Regexp.new("ível$") => [ 5, '', ["possível"] ],
                Regexp.new("ura$") => [ 4, '', ["imatura","acupuntura","costura"] ],
                Regexp.new("ual$") => [ 3, '', ["bissexual","virtual","visual","pontual"] ],
                Regexp.new("ial$") => [ 3, '' ],
                Regexp.new("al$") => [ 4, '', ["afinal","animal","estatal","bissexual","desleal","fiscal","formal","pessoal","liberal","postal","virtual","visual","pontual","sideral","sucursal"] ],
            }

            @rule[:verb] = {
                Regexp.new("aríamo$") => [ 2, ''],
                Regexp.new("eria$") => [ 3, '' ],
                Regexp.new("ássemo$") => [ 2, '' ],
                Regexp.new("ermo$") => [ 3, '' ],
                Regexp.new("eríamo$") => [ 2, '' ],
                Regexp.new("esse$") => [ 3, '' ],
                Regexp.new("êssemo$") => [ 2, '' ],
                Regexp.new("este$") => [ 3, '', ["faroeste","agreste"] ],
                Regexp.new("iríamo$") => [ 3, '' ],
                Regexp.new("íamo$") => [ 3, '' ],
                Regexp.new("íssemo$") => [ 3, '' ],
                Regexp.new("iram$") => [ 3, '' ],
                Regexp.new("áramo$") => [ 2, '' ],
                Regexp.new("íram$") => [ 3, '' ],
                Regexp.new("árei$") => [ 2, '' ],
                Regexp.new("irde$") => [ 2, '' ],
                Regexp.new("aremo$") => [ 2, '' ],
                Regexp.new("irei$") => [ 3, '', ["admirei"] ],
                Regexp.new("ariam$") => [ 2, '' ],
                Regexp.new("irem$") => [ 3, '', ["adquirem"] ],
                Regexp.new("aríei$") => [ 2, '' ],
                Regexp.new("iria$") => [ 3, '' ],
                Regexp.new("ássei$") => [ 2, '' ],
                Regexp.new("irmo$") => [ 3, '' ],
                Regexp.new("assem$") => [ 2, '' ],
                Regexp.new("isse$") => [ 3, '' ],
                Regexp.new("ávamo$") => [ 2, '' ],
                Regexp.new("iste$") => [ 4, '' ],
                Regexp.new("êramo$") => [ 3, '' ],
                Regexp.new("amo$") => [ 2, '' ],
                Regexp.new("eremo$") => [ 3, '' ],
                Regexp.new("ara$") => [ 2, '', ["arara","prepara"] ],
                Regexp.new("eriam$") => [ 3, '' ],
                Regexp.new("ará$") => [ 2, '', ["alvará"] ],
                Regexp.new("eríei$") => [ 3, '' ],
                Regexp.new("are$") => [ 2, '', ["prepare"] ],
                Regexp.new("êssei$") => [ 3, '' ],
                Regexp.new("ava$") => [ 2, '', ["agrava"] ],
                Regexp.new("essem$") => [ 3, '' ],
                Regexp.new("emo$") => [ 2, '' ],
                Regexp.new("íramo$") => [ 3, '' ],
                Regexp.new("era$") => [ 3, '', ["acelera","espera"] ],
                Regexp.new("iremo$") => [ 3, '' ],
                Regexp.new("erá$") => [ 3, '' ],
                Regexp.new("iriam$") => [ 3, '' ],
                Regexp.new("ere$") => [ 3, '', ["espere"] ],
                Regexp.new("iríei$") => [ 3, '' ],
                Regexp.new("iam$") => [ 3, '', ["enfiam","ampliam","elogiam","ensaiam"] ],
                Regexp.new("íssei$") => [ 3, '' ],
                Regexp.new("íei$") => [ 3, '' ],
                Regexp.new("issem$") => [ 3, '' ],
                Regexp.new("imo$") => [ 3, '', ["reprimo","intimo","íntimo","nimo","queimo","ximo"] ],
                Regexp.new("ando$") => [ 2, '' ],
                Regexp.new("ira$") => [ 3, '', ["fronteira","sátira"] ],
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
                Regexp.new("em$") => [ 2, '', ["alem","virgem"] ],
                Regexp.new("aste$") => [ 2, '' ],
                Regexp.new("er$") => [ 2, '', ["éter","pier"] ],
                Regexp.new("avam$") => [ 2, '' ],
                Regexp.new("eu$") => [ 3, '', ["chapeu"] ],
                Regexp.new("ávei$") => [ 2, '' ],
                Regexp.new("ia$") => [ 3, '', ["estória","fatia","acia","praia","elogia","mania","lábia","aprecia","polícia","arredia","cheia","ásia"] ],
                Regexp.new("eram$") => [ 3, '' ],
                Regexp.new("ir$") => [ 3, '' ],
                Regexp.new("erde$") => [ 3, '' ],
                Regexp.new("iu$") => [ 3, '' ],
                Regexp.new("erei$") => [ 3, '' ],
                Regexp.new("ou$") => [ 3, '' ],
                Regexp.new("êrei$") => [ 3, '' ],
                Regexp.new("i$") => [ 3, '' ],
                Regexp.new("erem$") => [ 3, '' ],
            }

            @rule[:adverb] = {
                Regexp.new("mente$") => [ 0, '', ["experimente"] ]
            }

            @rule[:vowel] = {
                Regexp.new("bil$") => [ 2, "vel" ],
                Regexp.new("gue$") => [ 2, "g", ["gangue","jegue"] ],
                Regexp.new("á$") => [ 3, ''], 
                Regexp.new("ê$") => [ 3, '', ["bebê"] ],
                Regexp.new("a$") => [ 3, '', ["ásia"] ],
                Regexp.new("e$") => [ 3, '' ],
                Regexp.new("o$") => [ 3, '',["ão"] ]
            }

            @rule[:accent] = {
                Regexp.new("[äâàáã]") => [0, 'a'],
                Regexp.new("[êéèë]") => [0, 'e'],
                Regexp.new("[ïîìí]") => [0, 'i'],
                Regexp.new("[üúùû]") => [0, 'u'],
                Regexp.new("[ôöóòõ]") => [0, 'o'],
                #Regexp.new("[ç]") => [0, 'c']
            }
        end

        def stem(term)
            apply_rule(:plural, term) if term =~ /s$/
            apply_rule(:femin, term) if term =~ /a$/
            apply_rule(:augment, term)
            apply_rule(:adverb, term)

            unless apply_rule(:noun, term)
                unless apply_rule(:verb, term)
                    apply_rule(:vowel, term)
                end
            end

            apply_rule(:accent, term)

            return term
        end

        private

        def apply_rule(rule_id, term)
            applied = false
            rule_to_apply = @rule[rule_id]

            rule_to_apply.each_pair do |re, operation| 
                if term =~ re && term.gsub(re, "").length >= operation[0] && ( operation[2].nil? || !operation[2].include?(term) )
                    term.gsub!(re, operation[1])
                    applied = true
                end
            end

            return applied
        end

    end

end
