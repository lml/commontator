# -*- encoding: utf-8 -*-
require File.expand_path('../lib/commontator/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Dante Soares"]
  gem.email         = ["dms3@rice.edu"]
  gem.description   = %q{Common Tator}
  gem.summary       = %q{A Rails engine for comments}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "commontator"
  gem.require_paths = ["lib"]
  gem.version       = Commontator::VERSION

  gem.add_dependency 'activerecord', '~> 3.2.4'
  gem.add_dependency 'acts_as_votable', '~> 0.3.1'
end
