
require_relative 'freqitem'

# TODO: Criar herança da classe Array e deixar de usar o atributo @freqitems
class FreqItemset

    COMPARE_SMALLER = 0
    COMPARE_EQUAL = 1
    COMPARE_LARGER = 2

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
        
        freq_itemset1.freqitems.each do |freqitem|
            add_freqitem(freqitem)
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
            return false if freq_itemset1.freqitems[pos1].freq_item_id != freq_itemset2.freqitems[pos2].freq_item_id
            
            pos1 += 1
            pos2 += 1
        end

        return true
    end
    
    # Returns COMPARE_EQUAL if target itemset is same as this itemset
    # Returns COMPARE_LARGER if the number of items in target itemset is larger
    # then this itemset OR the itemIDs are larger than this itemset;
    # Returns COMPARE_SMALLER otherwise.
    def compare_to(target_itemset)
    
        return COMPARE_LARGER  if target_itemset.freqitems.length > self.freqitems.length
        return COMPARE_SMALLER if target_itemset.freqitems.length < self.freqitems.length
        
        # Compare each frequent item's ID        
        self.freqitems.zip( target_itemset.freqitems ).each do |freq_item, target_freq_item|
            if target_freq_item.freq_item_id > freq_item.freq_item_id
                return COMPARE_LARGER
            elsif target_freq_item.freq_item_id < freq_item.freq_item_id
                return COMPARE_SMALLER
            end
        end
        
        return COMPARE_EQUAL
    end
    
    def print2
        puts "{ #{@freqitems.map(&:freq_item_id).to_s} } with Global Support = #{global_support}"
    end
end