
require_relative "controller"

global_support = 0.050000000745058060
cluster_support = 0.25
k_clusters = 30
input_dir = "./wap"

controller = Controller.new
controller.run global_support, cluster_support, k_clusters, input_dir
