$:.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'commontator/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |gem|
  gem.name        = 'commontator'
  gem.version     = COMMONTATOR_VERSION
  gem.authors     = [ 'Dante Soares' ]
  gem.email       = [ 'dante.m.soares@rice.edu' ]
  gem.homepage    = 'http://github.com/lml/commontator'
  gem.license     = 'MIT'
  gem.summary     = 'Allows users to comment on any model in your application.'
  gem.description = 'A Rails engine for comments.'

  gem.files = Dir['{app,config,db,lib,vendor}/**/*'] + [ 'MIT-LICENSE', 'Rakefile', 'README.md' ]
  gem.test_files = Dir['spec/**/*']

  gem.add_dependency 'rails', '>= 5.0'
  gem.add_dependency 'jquery-rails'

  gem.add_development_dependency 'rspec-rails'
  gem.add_development_dependency 'rails-controller-testing'
  gem.add_development_dependency 'listen'
  gem.add_development_dependency 'will_paginate'
  gem.add_development_dependency 'acts_as_votable'
  gem.add_development_dependency 'mailgun_rails'
end
