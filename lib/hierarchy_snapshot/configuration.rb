module HierarchySnapshot
  class Configuration
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
