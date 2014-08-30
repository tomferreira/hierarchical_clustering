
require_relative 'freqitem'

class FreqItemset < Array

    COMPARE_SMALLER = 0
    COMPARE_EQUAL = 1
    COMPARE_LARGER = 2

    attr_accessor :global_support
    #attr_reader :freqitems
    
    def initialize        
        @global_support = 0
        @num_global_support = 0
    end

    # Add a new frequent item into this itemset. 
    # No duplicated item and the resultant list is sorted, e.g. {101, 105, 120}
    def add_freqitem(new_freqitem)
        return if new_freqitem.nil?
        
        if empty?
            push( new_freqitem )
            return
        end
        
        new_id = new_freqitem.freq_item_id
        
        # for performance
        pos = self.length - 1
        
        self.reverse_each do |freqitem|        
            id = freqitem.freq_item_id

            if new_id == id
                # duplicated item
                return 
            elsif new_id > id
                insert(pos+1, new_freqitem)
                return
            end
            
            pos -= 1
        end
        
        # add head
        insert(0, new_freqitem)
    end
    
    # Return the frequent item that has the given item_id
    def get_freqitem(item_id)
        self.each do |freqitem|
            return freqitem if freqitem.freq_item_id == item_id
        end
        
        return nil
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
        return false if freq_itemset1.empty? || freq_itemset2.empty? || freq_itemset1.length != freq_itemset2.length
        
        freq_itemset1.each do |freqitem|
            add_freqitem(FreqItem.new(freqitem.freq_item_id))
        end
        
        add_freqitem(FreqItem.new(freq_itemset2.last.freq_item_id))
        
        return true
    end
    
    def self.joinable(freq_itemset1, freq_itemset2)
        return false if freq_itemset1.nil? || freq_itemset2.nil?
        return false if freq_itemset1.empty? || freq_itemset2.empty? || freq_itemset1.length != freq_itemset2.length
        
        pos1 = pos2 = 0
        tail1 = freq_itemset1.length-1
        tail2 = freq_itemset2.length-1
        
        while pos1 != tail1 && pos2 != tail2
            return false if freq_itemset1[pos1].freq_item_id != freq_itemset2[pos2].freq_item_id
            
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
    
        return COMPARE_LARGER  if target_itemset.length > self.length
        return COMPARE_SMALLER if target_itemset.length < self.length
        
        # Compare each frequent item's ID        
        self.zip( target_itemset ).each do |freq_item, target_freq_item|
            if target_freq_item.freq_item_id > freq_item.freq_item_id
                return COMPARE_LARGER
            elsif target_freq_item.freq_item_id < freq_item.freq_item_id
                return COMPARE_SMALLER
            end
        end
        
        return COMPARE_EQUAL
    end
    
    # Returns TRUE if the given frequent itemset is a subset of this frequent itemset; FALSE otherwise.  
    # Note: Assume both itemsets are sorted.
    def contains_all(target_itemset)
        return false if target_itemset.nil?
        
        pos = 0
        
        target_itemset.each do |target_freqitem|        
            
            id_target = target_freqitem.freq_item_id
            target_found = false
            
            self[pos..-1].each do |freqitem|
                pos += 1
                
                if freqitem.freq_item_id > id_target
                    return false 
                elsif freqitem.freq_item_id == id_target
                    # target found, check the next frequent item
                    target_found = true
                    break
                end
            end
            
            return false unless target_found
        end

        return true
    end
    
    def print2
        puts "{ #{self.map(&:freq_item_id).to_s} } with Global Support = #{global_support}"
    end
end