
require_relative 'freqitem'

class ClusterFreqItem < FreqItem

    def initialize(id, cluster_support)
        super(id)
        @cluster_support = cluster_support
    end

end