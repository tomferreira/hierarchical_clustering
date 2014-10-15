# sudo gem install unicode
# sudo gem install builder
# cd language_detector
# sudo gem build language_detector.gemspec
# sudo gem install language_detector-0.1.2.gem
# ruby fihc.rb

require 'parallel'
require_relative "controller"

global_support = 0.050000000000000003
cluster_support = 0.25
k_clusters = 30
input_dir = "./wap"

controller = Controller.new
controller.run global_support, cluster_support, k_clusters, input_dir
