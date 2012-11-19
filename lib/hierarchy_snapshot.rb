module HierarchySnapshot
  autoload :ActiveRecord, 'hierarchy_snapshot/active_record'
  autoload :Configuration, 'hierarchy_snapshot/configuration'

  class Snapshot < ::ActiveRecord::Base
    self.table_name = 'hierarchy_snapshots'
    belongs_to :source, :polymorphic => true
  end
end
