
require 'clustering/fihc/freqitem'

module Clustering::Fihc
    class ClusterFreqItem < FreqItem

        attr_accessor :cluster_support

        def initialize(id, cluster_support)
            super(id)
            @cluster_support = cluster_support
        end

    end
end