﻿
require 'clustering/fihc/document_manager'
require 'clustering/fihc/cluster_manager'

module Clustering::Fihc
    class OutputManager

        def initialize(out_file_path)
            @out_file_path = out_file_path
        end

        def produce_output( document_manager, cluster_manager )
            return if cluster_manager.nil?

            @document_manager = document_manager
            @cluster_manager = cluster_manager

            # get the root of the cluster tree
            root_cluster = @cluster_manager.cluster_warehouse.tree_root

            write_tree( root_cluster )
        end

    end
end