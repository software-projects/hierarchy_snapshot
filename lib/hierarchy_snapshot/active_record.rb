module HierarchySnapshot
  module ActiveRecord
    module ClassMethods
      def keep_hierarchy_snapshot(&bl)
        unless respond_to? :hierarchy_snapshot_save
          send :include, InstanceMethods
        end
        after_create :hierarchy_snapshot_save
        after_update :hierarchy_snapshot_save

        class_attribute :hierarchy_snapshot_config
        
        self.hierarchy_snapshot_config = Configuration.new.tap{|c| c.instance_eval(&bl)}
      end
    end

    module InstanceMethods
      def with_snapshot
        yield
        hierarchy_snapshot_save
      end

      def hierarchy_snapshot_save
        Snapshot.create :source => self, :data => hierarchy_snapshot_data
      end

      def hierarchy_snapshot_data
        hierarchy_snapshot_data_for(self, hierarchy_snapshot_config).to_json
      end

      def hierarchy_snapshot_data_for(obj, config)
        {}.tap do |map|
          config.attrs.each do |sym|
            map[sym] = obj.send(sym)
          end
          config.many(nil).each do |sym, config|
            map[sym] = obj.send(sym).to_a.collect do |child|
              hierarchy_snapshot_data_for(child, config)
            end
          end
        end
      end
    end
  end
end
