
class DocVector < Array

    attr_writer :freq_one_itemsets

    def convert_to_idf!(idf)
        raise 'error' if self.length != idf.length
        
        self.each_index do |i|
            self[i] = (self[i] * idf[i]).ceil
        end
    end
    
    # Get all the frequent items that presents in this document.
    # TODO: see better variable name
    def get_present_items(use_item_id)
        present_items = FreqItemset.new

        # for performance
        i = 0
        self.each do |item|
            if item > 0
                new_item = ( use_item_id ? FreqItem.new(get_freqitem_id(i)) : FreqItem.new(i) )
                present_items.add_freqitem(new_item)
            end
            
            i += 1
        end

        return present_items
    end
    
    # Add each element in the given vector to this vector.
    def add_up(doc_vector)
        
        if self.length != doc_vector.length
            raise 'error' if self.length != 0 && doc_vector.length != 0
            return
        end
        
        self.each_index do |i|
            self[i] += doc_vector[i]            
        end
    end

private

    # Given a vector UID, returns the corresponding Frequent Item ID
    def get_freqitem_id(vector_id)
    
        # TODO
        raise 'error' if @freq_one_itemsets.nil?
        
        @freq_one_itemsets[vector_id].first.freq_item_id    
    end
end
