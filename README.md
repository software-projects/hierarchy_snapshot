# HierarchySnapshot

This project adds the ability for ActiveRecord-based projects to automatically
maintain a snapshot of an object hierarchy when it is updated.

# Usage

This example was hastily taken from the test cases:

    class Parent < ActiveRecord::Base
      has_many :children                         # Standard association

      keep_hierarchy_snapshot do                 # Invoke the plugin
        attrs :name                              # Attributes to retrieve from 'self'
        many :children do                        # Associations to invoke on 'self'
          attrs :name                            # Attributes to retrieve from each child
          many :grandchildren do                 # Associations to invoke on each child
            attrs :name                          # Attributes to retrieve from each grandchild
          end
        end
      end
    end

When a parent object is created, like:

    p = Parent.create :name => 'test',
      :children_attributes => [ {:name => 'test2',
        :grandchildren_attributes => [ {:name => 'test3'} ],
    } ]

This will create a snapshot containing a JSON object that looks like:

    {"name":"test",
      "children":[{"name":"test2",
        "grandchildren":[{"name":"test3"}]
      }]
    }

Creating a snapshot when the child records are updated directly requires:

    p = Parent.find params[:id]
    p.with_snapshot do
      p.children.first.update_attributes! :name => 'test3'
    end

Creating an object without triggering a snapshot:

    p = Parent.find params[:id]
    p.without_snapshot do
      p.update_attributes! :name => 'test2'
    end

Requiring a user to be recorded with a snapshot:

    class Parent < ActiveRecord::Base
      has_many :children

      keep_hierarchy_snapshot do
        require_user
        attrs :name
      end
    end

    p = Parent.find params[:id]
    p.name = 'test2'
    p.save                                       # Throws an exception
    p.snapshot_user = current_user               # snapshot_user is automatically added to your snapshotted models
    p.save                                       # Works correctly

or

    p = Parent.find params[:id]

    p.with_snapshot do
      p.children.create :name => 'test2'
    end                                          # Throws an exception

    p.with_snapshot current_user do
      p.children.create :name => 'test2'
    end                                          # Works correctly
