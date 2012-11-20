$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "hierarchy_snapshot/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "hierarchy_snapshot"
  s.version     = HierarchySnapshot::VERSION
  s.authors     = ["Shaun Mangelsdorf"]
  s.email       = ["s.mangelsdorf@gmail.com"]
  s.homepage    = "https://github.com/smangelsdorf/hierarchy_snapshot"
  s.summary     = "Add object hierarchy snapshot capabilities to ActiveRecord"
  s.description = "This project adds the ability for ActiveRecord-based projects to automatically maintain a snapshot of an object hierarchy when it is updated."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]

  s.add_development_dependency "rails", ">= 3.0", '< 3.3'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'ruby-debug'
end
