
require_relative "controller"

class HierarchicalClustering

  def self.fihc(global_support, cluster_support, k_clusters, input_dir)
    controller = Controller.new
    controller.run global_support, cluster_support, k_clusters, input_dir
  end

end
