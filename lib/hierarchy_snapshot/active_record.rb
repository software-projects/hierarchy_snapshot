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
        attr_accessor :snapshot_user
        
        self.hierarchy_snapshot_config = Configuration.new(true).tap{|c| c.instance_eval(&bl)}
      end

      def without_snapshot
        old = Thread.current[:skip_hierarchy_snapshot]
        begin
          Thread.current[:skip_hierarchy_snapshot] = true
          return yield
        ensure
          Thread.current[:skip_hierarchy_snapshot] = old
        end
      end
    end

    module InstanceMethods
      def with_snapshot(user=nil)
        self.snapshot_user = user
        yield
        hierarchy_snapshot_save
      end

      def without_snapshot(&bl)
        self.class.without_snapshot(&bl)
      end

      def hierarchy_snapshot_save
        return if Thread.current[:skip_hierarchy_snapshot]

        if hierarchy_snapshot_config.require_user? and snapshot_user.nil?
          raise 'No snapshot user was specified, but one is required'
        end
        Snapshot.create :source => self, :data => hierarchy_snapshot_data, :user => snapshot_user
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
