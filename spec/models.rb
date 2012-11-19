class Parent < ActiveRecord::Base
  has_many :children

  attr_accessible :name, :children_attributes
  accepts_nested_attributes_for :children, :allow_destroy => true
end

class Child < ActiveRecord::Base
  belongs_to :parent
  has_many :grandchildren

  attr_accessible :name, :grandchildren_attributes
  accepts_nested_attributes_for :grandchildren, :allow_destroy => true
end

class Grandchild < ActiveRecord::Base
  belongs_to :child

  attr_accessible :name
end
