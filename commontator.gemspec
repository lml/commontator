$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "commontator/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "commontator"
  s.version     = Commontator::VERSION
  s.authors     = ["Dante Soares"]
  s.email       = ["dms3@rice.edu"]
  s.homepage    = "http://github.com/lml/commontator"
  s.license = 'MIT'
  s.summary     = "Allows users to comment on any model in your application."
  s.description = "A Rails engine for comments."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", ">= 4.0"
  s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "minitest-rails"
  s.add_development_dependency "acts_as_votable"
end
