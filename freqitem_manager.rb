
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
        
            timers = Array.new(5, 0)
        
            puts "F#{count-1} size [#{@kminus_itemsets.length}]"
            
            start = Time.now
            return false unless join_kcandidate_sets(freqk_itemsets)
            timers[0] = (Time.now - start)
            
            start = Time.now
            locate_position(freqk_itemsets)
            timers[1] = (Time.now - start)
            
            start = Time.now
            prune_kcandidate_sets(freqk_itemsets)
            timers[2] = (Time.now - start)
            
            start = Time.now
            find_min_global_support(freqk_itemsets)
            timers[3] = (Time.now - start)
            
            break if freqk_itemsets.length == 0
            
            @kminus_itemsets.clear
            
            start = Time.now
            
            freqk_itemsets.each do |freq_itemset|            
                @kminus_itemsets << freq_itemset
                @global_freq_itemsets << freq_itemset            
            end
            
            timers[4] = (Time.now - start)
            
            freqk_itemsets.clear
            count += 1
            
            puts "Duration: #{timers.inspect}"

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
            id = freqitemset.first.freq_item_id

            @index_freq_itemset[id] = pos if @index_freq_itemset[id].nil?
        end
    end
    
    def prune_kcandidate_sets(freqk_itemsets)
        return false if freqk_itemsets.nil?
        
        # TODO: Fazer!!
=begin
        freqtemp = FreqItemset.new
        
        freqk_itemsets.each_with_index do |freq_candidateset, pos|
            
            id = freq_candidateset.second.freq_item_id
            
            start, end = find_interval(id)
            
            freq_candidateset[1..-1].each do |freqitem|
                freqtemp.add_freqitem(freqitem)
            end
            
            unless is_in_kminus(start, end, freqtemp)
                temp = pos
            else
                id = freq_candidateset.first.freq_item_id
                
                start, end = find_interval(id)
                
                freq_candidateset[1..-2].each do |freqitem|
                    freqtemp.clear
                    
                    
                end
            end
        end
=end
    end
    
    def find_min_global_support(freqk_itemsets)
        raise 'error' if freqk_itemsets.nil?

        counts = Parallel.map(freqk_itemsets) do |freq_itemset|            
            count = 0

            @documents.each do |doc|
                doc_vector = doc.doc_vector
                incr = true

                freq_itemset.each do |freq_item|
                    # didn't contain this itemset
                    if doc_vector[freq_item.freq_item_id] <= 0
                        incr = false
                        break
                    end                    
                end

                # contain this itemset
                count += 1 if incr
            end
            
            count
        end
        
        freqk_itemsets.each_with_index do |freq_itemset, i|
            freq_itemset.increment_num_global_support(counts[i])
            
            freq_itemset.calculate_global_support(@documents.length)
        end

        freqk_itemsets.delete_if do |freq_itemset|
            freq_itemset.global_support < @min_global_support
        end
    end

end
