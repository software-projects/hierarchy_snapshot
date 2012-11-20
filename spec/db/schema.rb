ActiveRecord::Schema.define(:version => 0) do
  create_table :parents, :force => true do |t|
    t.string :name
    t.timestamps
  end

  create_table :children, :force => true do |t|
    t.integer :parent_id
    t.string :name
    t.timestamps
  end

  create_table :grandchildren, :force => true do |t|
    t.integer :child_id
    t.string :name
    t.timestamps
  end

  create_table :hierarchy_snapshots, :force => true do |t|
    t.integer :source_id
    t.string :source_type
    t.integer :user_id
    t.string :user_type
    t.text :data
    t.timestamp :created_at
  end

  create_table :users, :force => true do |t|
    t.string :name
    t.timestamps
  end
end
