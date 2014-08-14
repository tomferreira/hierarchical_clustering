
class FreqItemManager

    attr_writer :min_global_support

    def mine_global_freqitemsets( documents, f1 )
        puts "*** Computing global frequent itemsets using Apriori"

        return false unless documents

        @documents = documents
        @f1 = f1
    end

    def global_freqitemsets

    end

end
