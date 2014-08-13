
require_relative "controller"

global_support = true
cluster_support = true
k_clusters = 10
input_dir = ""

controller = Controller.new
controller.run global_support, cluster_support, k_clusters, input_dir