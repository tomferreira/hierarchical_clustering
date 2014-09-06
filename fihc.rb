# sudo gem install builder
# sudo gem install feedbackmine-language_detector
# ruby fihc.rb

require_relative "controller"

global_support = 0.050000000000000003
cluster_support = 0.25
k_clusters = 30
input_dir = "./wap"

controller = Controller.new
controller.run global_support, cluster_support, k_clusters, input_dir
