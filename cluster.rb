
require_relative 'cluster_freqitemset'
require_relative 'cluster_freqitem'

class Cluster

    UNTOUCHED = 0
    
    attr_reader :core_items, :num_core_items

    def initialize(freqitemset)
    
        @core_items = ClusterFreqItemset.new
    
        @tree_parent = nil
        
        freqitemset.freqitems.each do |coreitem|
            # TODO
            @core_items.add_freqitem(ClusterFreqItem.new(coreitem.freq_item_id, 0.0))
        end
        
        # the global support of this core itemset
        @core_items.global_support = freqitemset.global_support

        # Cache the number of core items (for efficiency)
        # This is unlikley to change within lifetime of this instance.
        # However, if core items are updated, remember to update this counter.
        @num_core_items = @core_items.freqitems.length
        @status = UNTOUCHED        
    end
    
    # Get the itemID of the first core item
    def first_core_item_id
        @core_items.freqitems.first
    end
    
end