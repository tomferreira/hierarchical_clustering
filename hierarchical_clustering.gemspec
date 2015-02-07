Gem::Specification.new do |s|
  s.name        = 'hierarchical_clustering'
  s.version     = '0.0.6'
  s.date        = '2014-10-01'
  s.summary     = %q{Library for a bunch of hierarchical clustering algorithms}
  s.description = %q{Library for a bunch of hierarchical clustering algorithms}
  s.authors     = ["Cirillo Ferreira"]
  s.email       = %q{cirillo.ferreira@gmail.com}
  s.files       = `git ls-files`.split($/)
  s.homepage    = %q{http://rubygems.org/gems/hierarchical_clustering}
  s.license       = 'MIT'
  s.require_paths = ["lib"]
  
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = %(>=2.0.0)

  s.add_dependency 'builder', '~> 3.2'
  s.add_dependency 'unicode', '~> 0.4'
  s.add_dependency 'parallel', '~> 1.3'
  s.add_dependency 'rubysl-jcode', '~> 1.0'
  s.add_dependency 'feedbackmine-language_detector', '~> 0.1', '>= 0.1.2'
end
