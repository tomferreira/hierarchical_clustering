

class FreqItemset

    attr_accessor :global_support
    attr_reader :freqitems
    
    def initialize
        @freqitems = []
        
        @global_support = 0
        @num_global_support = 0
    end

    def add_freqitem(freqitem)
        @freqitems << freqitem
    end
    
    def calculate_global_support(num_docs)
        raise "num_docs is zero or minor" if num_docs <= 0
        
        @global_support = @num_global_support.to_f / num_docs
    end
    
    def increment_num_global_support
        @num_global_support += 1
    end
    
    def join(freq_itemset1, freq_itemset2)
        return false if freq_itemset1.nil? || freq_itemset2.nil?
        return false if freq_itemset1.freqitems.empty? || freq_itemset2.freqitems.empty? || freq_itemset1.freqitems.length != freq_itemset2.freqitems.length
        
        freq_itemset1.freqitems.each do |id|
            add_freqitem(id)
        end
        
        add_freqitem(freq_itemset2.freqitems.last)
        
        return true
    end
    
    def self.joinable(freq_itemset1, freq_itemset2)
        return false if freq_itemset1.nil? || freq_itemset2.nil?
        return false if freq_itemset1.freqitems.empty? || freq_itemset2.freqitems.empty? || freq_itemset1.freqitems.length != freq_itemset2.freqitems.length
        
        pos1 = pos2 = 0
        tail1 = freq_itemset1.freqitems.length-1
        tail2 = freq_itemset2.freqitems.length-1
        
        while pos1 != tail1 && pos2 != tail2
            return false if freq_itemset1.freqitems[pos1] != freq_itemset2.freqitems[pos2]
            
            pos1 += 1
            pos2 += 1
        end

        return true        
    end
end