

class FreqItemset

    attr_writer :global_support
    
    def initialize
        @freqitems = []
    end

    def add_freqitem(freqitem)
        @freqitems << freqitem
    end
end