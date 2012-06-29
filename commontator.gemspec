$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "commontator/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "commontator"
  s.version     = Commontator::VERSION
  s.authors     = ["Dante Soares"]
  s.email       = ["dms3@rice.edu"]
  s.homepage    = "http://rubygems.org/gems/commontator"
  s.summary     = "Common Tator"
  s.description = "A Rails engine for comments."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.0.0"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
end
