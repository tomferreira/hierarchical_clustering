
module Clustering::Fihc
    class FreqItemManager

        attr_reader :global_freq_itemsets

        def initialize(min_global_support)
            @min_global_support = min_global_support
        end

        def mine_global_freqitemsets( documents, f1sets )
            puts "*** Computing global frequent itemsets using Apriori" if Configuration.debug

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

                puts "F#{count-1} size [#{@kminus_itemsets.length}]" if Configuration.debug

                start = Time.now
                return false unless join_kcandidate_sets(freqk_itemsets)
                timers[0] = (Time.now - start)

                start = Time.now
                locate_position(@kminus_itemsets)
                
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

                puts "Duration: #{timers.inspect}" if Configuration.debug

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

        def prune_kcandidate_sets(freqk_itemsets)
            return false if freqk_itemsets.nil?

            freqtemp = FreqItemset.new
            temp = nil

            freqk_itemsets.each_with_index do |freq_candidate_set, pos|

                id = freq_candidate_set[1].freq_item_id

                start_interval, end_interval = find_interval(id)

                freq_candidate_set[1..-1].each { |freqitem| freqtemp.add_freqitem(freqitem) }

                unless is_in_kminus(start_interval, end_interval, freqtemp)
                    temp = pos
                else
                    id = freq_candidate_set[0].freq_item_id

                    start_interval, end_interval = find_interval(id)

                    freq_candidate_set[1..-2].each do |freqitem|
                        freqtemp.clear

                        freq_candidate_set.each do |freqitem2|
                            freqtemp.add_freqitem(freqitem2) if freqitem2 != freqitem
                        end

                        unless is_in_kminus(start_interval, end_interval, freqtemp)
                            temp = pos
                            break
                        end
                    end               
                end

                freqtemp.clear

                unless temp.nil?
                    freqk_itemsets.delete_at(temp)
                    temp = nil                
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

        def find_interval(id)
            start_interval = nil
            end_interval = nil

            start_interval = @index_freq_itemset[id] unless @index_freq_itemset[id].nil?

            temp_id = id + 1

            while temp_id < @numF1

                unless @index_freq_itemset[temp_id].nil?
                    end_interval = @index_freq_itemset[temp_id]
                    break
                end

                temp_id += 1

            end

            return start_interval, end_interval
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

        def is_in_kminus(start_interval, end_interval, itemset)

            raise 'error' if itemset.nil?

            pos_kminus = start_interval.nil? ? 0 : start_interval
            end_kminus = end_interval.nil? ? @kminus_itemsets.length-1 : end_interval

            while pos_kminus != end_kminus

                equal = true

                freq_kminusset = @kminus_itemsets[pos_kminus]
                raise 'error' if freq_kminusset.nil?

                freq_kminusset.each_with_index do |freqitem, pos|
                    item_id1 = itemset[pos].freq_item_id
                    item_id2 = freqitem.freq_item_id

                    # Two itemsets are not equal
                    if item_id1 != item_id2 
                        equal = false
                        break 
                    end
                end

                break if equal # Found the matching itemset

                pos_kminus += 1
            end

            return pos_kminus != end_kminus        
        end

    end
end