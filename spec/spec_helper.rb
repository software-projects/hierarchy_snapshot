Bundler.require :development
require 'active_record'
require 'hierarchy_snapshot'

require 'logger'

plugin_spec_dir = File.dirname(__FILE__)
ActiveRecord::Base.logger = Logger.new(File.join(plugin_spec_dir, '..', 'log', 'debug.log'))

databases = YAML::load(IO.read(File.join(plugin_spec_dir, 'db', 'database.yml')))
ActiveRecord::Base.establish_connection(databases[ENV['DB'] || 'sqlite3'])

ActiveRecord::Base.send :extend, HierarchySnapshot::ActiveRecord::ClassMethods

require File.join(plugin_spec_dir, 'db', 'schema.rb')
require 'models.rb'
