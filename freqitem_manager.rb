
class FreqItemManager

    attr_writer :min_global_support
    attr_reader :global_freq_itemsets

    def mine_global_freqitemsets( documents, f1sets )
        puts "*** Computing global frequent itemsets using Apriori"

        return false unless documents

        @documents = documents
        @f1sets = f1sets
                
        @kminus_itemsets = @f1sets.clone        
        @global_freq_itemsets = @f1sets.clone
        
        @numF1 = @f1sets.length
        @index_freq_itemset = Array.new(@numF1)
        
        freqk_itemsets = []

        count = 2
        
        begin
            puts "F#{count-1} size [#{@kminus_itemsets.length}]"
            
            return false unless join_kcandidate_sets(freqk_itemsets)
            
            locate_position(freqk_itemsets)
            
            prune_kcandidate_sets(freqk_itemsets)
            
            return false unless find_min_global_support(freqk_itemsets)
            
            break if freqk_itemsets.length == 0
            
            @kminus_itemsets.clear
            
            freqk_itemsets.each do |freq_itemset|
            
                @kminus_itemsets << freq_itemset
                @global_freq_itemsets << freq_itemset
            
            end
            
            freqk_itemsets.clear
            count += 1

        end while count < @numF1
        
        return true
    end
    
private

    def join_kcandidate_sets(freqk_itemsets)
    
        @kminus_itemsets.each_with_index do |freq_itemset1, pos1|
        
            @kminus_itemsets[pos1+1..-1].each do |freq_itemset2|

                if FreqItemset::joinable(freq_itemset1, freq_itemset2)                
                    freq_candidate_set = FreqItemset.new
                    freqk_itemsets << freq_candidate_set if freq_candidate_set.join(freq_itemset1, freq_itemset2)
                end

            end

        end

    end
    
    def locate_position(freqk_itemsets)
        return if freqk_itemsets.nil?
        
        @numF1.times { |i| @index_freq_itemset[i] = nil }
        
        freqk_itemsets.each_with_index do |freqitemset, pos|
            id = freqitemset.freqitems.first.freq_item_id

            @index_freq_itemset[id] = pos if @index_freq_itemset[id].nil?
        end
    end
    
    def prune_kcandidate_sets(freqk_itemsets)
        return false if freqk_itemsets.nil?
        
        # TODO                
    end
    
    def find_min_global_support(freqk_itemsets)
        return false if freqk_itemsets.nil?
        
        @documents.each do |doc|
        
            freqk_itemsets.each do |freq_itemset|
            
                incr = true
            
                freq_itemset.freqitems.each do |freq_item|
                
                    # didn't contain this itemset
                    if doc.doc_vector[freq_item.freq_item_id] <= 0
                        incr = false
                        break
                    end                    
                end
                
                # contain this itemset
                freq_itemset.increment_num_global_support if incr            
            end        
        end
        
        freqk_itemsets.delete_if do |freq_itemset|
            freq_itemset.calculate_global_support(@documents.length)
            
            freq_itemset.global_support < @min_global_support
        end
        
    end

end
