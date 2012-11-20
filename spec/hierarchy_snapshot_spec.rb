require File.join(File.dirname(__FILE__), 'spec_helper')
require 'hierarchy_snapshot'

describe HierarchySnapshot do
  def last_snapshot_obj
    JSON.load HierarchySnapshot::Snapshot.last.data
  end

  it 'can be included in an ActiveRecord model' do
    class A < ActiveRecord::Base
      self
    end.should respond_to :keep_hierarchy_snapshot
  end

  it 'records a copy of the object when it is saved' do
    class Parent < ActiveRecord::Base
      keep_hierarchy_snapshot do
        attrs :name
      end
    end

    lambda {
      Parent.create :name => 'test'
    }.should change(HierarchySnapshot::Snapshot, :count).by(1)

    obj = last_snapshot_obj
    obj['id'].should be_nil
    obj['name'].should == 'test'
  end

  it 'excludes the name when not configured' do
    class Parent < ActiveRecord::Base
      keep_hierarchy_snapshot do
        attrs :id
      end
    end

    t = nil
    lambda {
      t = Parent.create :name => 'test'
    }.should change(HierarchySnapshot::Snapshot, :count).by(1)

    obj = last_snapshot_obj
    obj['id'].to_s.should == t.id.to_s
    obj['name'].should be_nil
  end

  it 'includes a child when one is configured' do
    class Parent < ActiveRecord::Base
      keep_hierarchy_snapshot do
        attrs :name
        many :children do
          attrs :name
        end
      end
    end

    lambda {
      t = Parent.new :name => 'test'
      t.children << Child.new(:name => 'test2')
      t.save!
    }.should change(HierarchySnapshot::Snapshot, :count).by(1)

    obj = last_snapshot_obj
    obj['name'].should == 'test'
    obj['children'].should_not be_nil
    obj['children'].should_not be_empty
    obj['children'][0]['name'].should == 'test2'
  end

  it 'includes a grandchild when one is configured' do
    class Parent < ActiveRecord::Base
      keep_hierarchy_snapshot do
        attrs :name
        many :children do
          attrs :name
          many :grandchildren do
            attrs :name
          end
        end
      end
    end

    lambda {
      t = Parent.create :name => 'test',
        :children_attributes => [ {:name => 'test2',
          :grandchildren_attributes => [ {:name => 'test3'} ],
      } ]
    }.should change(HierarchySnapshot::Snapshot, :count).by(1)

    obj = last_snapshot_obj
    obj['name'].should == 'test'
    obj['children'][0]['name'].should == 'test2'
    obj['children'][0]['grandchildren'][0]['name'].should == 'test3'
  end

  it 'rewrites the hierarchy after an update when the parent has no changes' do
    class Parent < ActiveRecord::Base
      keep_hierarchy_snapshot do
        attrs :name
        many :children do
          attrs :name
        end
      end
    end

    p = Parent.create :name => 'test'
    lambda {
      p.update_attributes! :children_attributes => [{:name => 'test2'}]
    }.should change(HierarchySnapshot::Snapshot, :count).by(1)

    obj = last_snapshot_obj
    obj['name'].should == 'test'
    obj['children'][0]['name'].should == 'test2'
  end

  it 'rewrites the hierarchy after a grandchild deletion with no other changes made' do
    class Parent < ActiveRecord::Base
      keep_hierarchy_snapshot do
        attrs :name
        many :children do
          attrs :name
          many :grandchildren do
            attrs :name
          end
        end
      end
    end

    p = Parent.create :name => 'test',
      :children_attributes => [ {:name => 'test2',
        :grandchildren_attributes => [ {:name => 'test3'} ],
    } ]

    lambda {
      c = p.children[0]
      g = c.grandchildren[0]
      p.update_attributes! :children_attributes => [{:id => c.id,
        :grandchildren_attributes => [{:id => g.id, :_destroy => true}]}]
    }.should change(HierarchySnapshot::Snapshot, :count).by(1)

    obj = last_snapshot_obj
    obj['children'][0]['grandchildren'].should be_empty
  end

  it 'requires a snapshot to be manually triggered when writing a child directly' do
    class Parent < ActiveRecord::Base
      keep_hierarchy_snapshot do
        attrs :name
        many :children do
          attrs :name
          many :grandchildren do
            attrs :name
          end
        end
      end
    end

    p = Parent.create :name => 'test',
      :children_attributes => [ {:name => 'test2'} ]

    lambda {
      p.children[0].update_attributes! :name => 'test4'
    }.should_not change(HierarchySnapshot::Snapshot, :count)

    lambda {
      p.children.create :name => 'test6'
    }.should_not change(HierarchySnapshot::Snapshot, :count)

    lambda {
      p.with_snapshot do
        p.children[0].update_attributes! :name => 'test5'
      end
    }.should change(HierarchySnapshot::Snapshot, :count).by(1)

    obj = last_snapshot_obj
    obj['children'][0]['name'].should == 'test5'
  end

  it 'skips creating a snapshot when required' do
    class Parent < ActiveRecord::Base
      keep_hierarchy_snapshot do
        attrs :name
      end
    end

    lambda {
      Parent.without_snapshot do
        Parent.create :name => 'test'
      end
    }.should_not change(HierarchySnapshot::Snapshot, :count)

    lambda {
      Parent.create :name => 'test2'
    }.should change(HierarchySnapshot::Snapshot, :count).by(1)
  end

  it 'requires a user object when configured' do
    class Parent < ActiveRecord::Base
      keep_hierarchy_snapshot do
        require_user
        attrs :name
      end
    end

    lambda {
      Parent.create :name => 'test'
    }.should raise_error

    lambda {
      p = Parent.new :name => 'test'
      p.snapshot_user = User.create :name => 'testuser'
      p.save!
    }.should change(HierarchySnapshot::Snapshot, :count).by(1)

    HierarchySnapshot::Snapshot.last.user.name.should == 'testuser'
  end

  it 'requires a user object when manually triggering a snapshot' do
    class Parent < ActiveRecord::Base
      keep_hierarchy_snapshot do
        require_user
        attrs :name
      end
    end

    p = nil
    Parent.without_snapshot do
      p = Parent.create :name => 'test'
    end
    lambda {
      p.with_snapshot do
        p.children.create :name => 'test'
      end
    }.should raise_error

    lambda {
      p.with_snapshot(User.create(:name => 'testuser')) do
        p.children.create :name => 'test'
      end
    }.should change(HierarchySnapshot::Snapshot, :count).by(1)

    HierarchySnapshot::Snapshot.last.user.name.should == 'testuser'
  end
end
