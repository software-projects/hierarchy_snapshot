module HierarchySnapshot
  class Configuration
    def initialize(top=false)
      @top = top
    end

    def require_user
      raise 'Only valid at top level' unless @top
      @require_user = true
    end

    def require_user?
      !!@require_user
    end

    def attrs(*args)
      @attrs ||= []
      @attrs += args.flatten
      @attrs
    end

    def many(assoc, &bl)
      @many ||= {}
      @many[assoc] = Configuration.new.tap{|c| c.instance_eval(&bl)} unless assoc.nil?
      @many
    end
  end
end
