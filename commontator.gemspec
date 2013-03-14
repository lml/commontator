# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "commontator/version"

Gem::Specification.new do |gem|
  gem.name          = "commontator"
  gem.version       = Commontator::VERSION
  gem.authors       = ["Dante Soares"]
  gem.email         = ["dms3@rice.edu"]
  gem.description   = "A Rails engine for comments."
  gem.summary       = "Common Tator"
  gem.homepage      = "http://rubygems.org/gems/commontator"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "rails", ">= 3.1"
  gem.add_dependency "jquery-rails"

  gem.add_development_dependency "sqlite3"
  gem.add_development_dependency "minitest-rails"
  gem.add_development_dependency "acts_as_votable"
end
