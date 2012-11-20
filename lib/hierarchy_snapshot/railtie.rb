require 'hierarchy_snapshot'
require 'rails'

module HierarchySnapshot
  class Railtie < Rails::Railtie
    initializer 'hierarchy_snapshot.active_record_hooks' do
      ::ActiveRecord::Base.send :extend, HierarchySnapshot::ActiveRecord::ClassMethods
    end
  end
end
