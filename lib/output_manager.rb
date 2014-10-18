
require_relative 'document_manager'
require_relative 'cluster_manager'

class OutputManager

    def initialize( document_manager, cluster_manager )
        @document_manager = document_manager
        @cluster_manager = cluster_manager
    end

    def produce_output( out_file_path )
        return if @cluster_manager.nil?
        
        # get the root of the cluster tree
        root_cluster = @cluster_manager.cluster_warehouse.tree_root
        
        write_tree( out_file_path, root_cluster )
    end
    
protected

    def write_tree; end

end