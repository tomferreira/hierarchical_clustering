
class DocVector < Array

    attr_writer :freq_one_itemsets

    def convert_to_idf!(idf)

        return false if self.length != idf.length
        
        each_index do |i|
            self[i] = (self[i] * idf[i]).ceil
        end
    end
end
