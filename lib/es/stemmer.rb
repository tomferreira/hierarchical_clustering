
# Spanish Stemming
# 
# = Description
# This class is for reducing Spanish words to their roots. It uses an algorithm
# based on Martin Porter's specifications.
#  
# For more information, visit:
# https://github.com/MaG21/estem
# http://snowball.tartarus.org/algorithms/spanish/stemmer.html
# 

module Stemmer

    class Spanish

        VOWEL = 'aeiouáéíóúüAEIOUÁÉÍÓÚÜ'
        CONSONANT = "bcdfghjklmnñpqrstvwxyzABCDEFGHIJKLMNÑOPQRSTUVWXYZ"   
       
        
        def stem(term)

            case term.length
            when 0
                return term
            when 1
                return remove_accent(term)
            end

            step0(term)

            unless step1(term)
                step2b(term) unless step2a(term)
            end

            step3(term)
            remove_accent(term)

            term
        end

    private

        def vowel?(c)
            VOWEL.include?(c)
        end

        def consonant?(c)
            CONSONANT.include?(c)
        end

        def remove_accent(str)
            str.tr('áéíóúÁÉÍÓÚ','aeiouAEIOU')
        end

        def rv(str)
            if consonant? str[1]
                i=2
                i+=1 while str[i] and consonant? str[i]
                return str.nil? ? str.length-1 : i+1
            end

            if vowel? str[0] and vowel? str[1]
                i=2
                i+=1 while str[i] and vowel? str[i]
                return str.nil? ? str.length-1 : i+1
            end

            return 3 if consonant? str[0] and vowel? str[1]

            str.length - 1
        end

        def r(str, i=0)
            i+=1 while str[i] and consonant?(str[i])
            i+=1
            i+=1 while str[i] and vowel? str[i]
            str[i].nil? ?  str.length : i+1
        end

        def r12(str)
            r1 = r(str)
            r2 = r(str,r1)
            [r1,r2]
        end

        #=> true or false
        def step0(str)
            return false unless str =~ /(se(l[ao]s?)?|l([aeo]s?)|me|nos)$/i

            suffix = $&
            rv_text = str[rv(str)..-1]

            case rv_text
            when %r{((?<=i[éÉ]ndo|[áÁ]ndo|[áéíÁÉÍ]r)#{suffix})$}ui
                str[%r{#$&$}]=''
                str.replace(remove_accent(str))
                return true
            when %r{((?<=iendo|ando|[aei]r)#{suffix})$}i
                str[%r{#$&$}]=''
                return true
            end

            if rv_text =~ /yendo/i and str =~ /uyendo/i
                  str[suffix]=''
                  return true
            end
            false
        end

        #=> true or false
        def step1(str)
            r1,r2 = r12(str)
            r1_text = str[r1..-1]
            r2_text = str[r2..-1]

            case r2_text
            when /(anzas?|ic[oa]s?|ismos?|[ai]bles?|istas?|os[oa]s?|[ai]mientos?)$/i
                str[%r{#$&$}]=''
                return true
            when /(ic)?(ador([ae]s?)?|aci[óÓ]n|aciones|antes?|ancias?)$/ui
                str[%r{#$&$}]=''
                return true
            when /log[íÍ]as?/ui
                str[%r{#$&$}]='log'
                return true
            when /(uci([óÓ]n|ones))$/ui
                str[%r{#$&$}]='u'
                return true
            when /(encias?)$/i
                str[%r{#$&$}]='ente'
                return true
            end

            if r2_text =~ /(ativ|iv|os|ic|ad)amente$/i or r1_text =~ /amente$/i
                str[%r{#$&$}]=''
                return true
            end

            case r2_text
            when /((ante|[ai]ble)?mente)$/i, /((abil|i[cv])?idad(es)?)$/i, /((at)?iv[ao]s?)$/i
                str[%r{#$&$}]=''
                return true
            end
            false
        end

        #=> true or false
        def step2a(str)
            rv_pos = rv(str)
            idx = str[rv_pos..-1] =~ /(y[oóÓ]|ye(ron|ndo)|y[ae][ns]?|ya(is|mos))$/ui

            return false unless idx

            if 'u' == str[rv_pos+idx-1].downcase
                str[%r{#$&$}] = ''
                return true
            end
            false
        end

        STEP2B_REGEXP = /(
            ar([áÁ][ns]?|a(n|s|is)?|on)? | ar([éÉ]is|emos|é|É) | ar[íÍ]a(n|s|is|mos)? |
            er([áÁ][sn]?|[éÉ](is)?|emos|[íÍ]a(n|s|is|mos)?)? |
            ir([íÍ]a(s|n|is|mos)?|[áÁ][ns]?|emos|[éÉ]|éis)? | aba(s|n|is)? |
            ad([ao]s?)? | ed | id(a|as|o|os)? | [íÍ]a(n|s|is|mos)? | [íÍ]s |
            as(e[ns]?|te|eis|teis)? | [áÁ](is|bamos|semos|ramos) | a(n|ndo|mos) |
            ie(ra|se|ran|sen|ron|ndo|ras|ses|rais|seis) | i(ste|steis|[óÓ]|mos|[éÉ]ramos|[éÉ]semos) |
            en|es|[éÉ]is|emos
        )$/xiu

        #=> true or false
        def step2b(str)
            rv_pos =  rv(str)

            if idx = str[rv_pos..-1] =~ STEP2B_REGEXP
                suffix = $&
                if suffix =~ /^(en|es|[éÉ]is|emos)$/ui
                    str[%r{#{suffix}$}]=''
                    str[rv_pos+idx-1]='' if str[rv_pos+idx-2] =~ /g/i and  str[rv_pos+idx-1] =~ /u/i
                else
                    str[%r{#{suffix}$}]=''
                end
                return true
            end
            false
        end

        #=> true or false
        def step3(str)
            rv_pos = rv(str)
            rv_text = str[rv_pos..-1]

            if rv_text =~ /(os|[aoáíóÁÍÓ])$/ui
                str[%r{#$&$}]=''
                return true
            elsif idx = rv_text =~ /(u?[eéÉ])$/i
                if $&[0].downcase == 'u' and str[rv_pos+idx-1].downcase == 'g'
                    str[%r{#$&$}]=''
                else
                    str.chop!
                end
                return true
            end
            false
        end    
    end

end