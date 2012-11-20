class <%= class_name %> < ActiveRecord::Migration
  def self.up
    create_table :hierarchy_snapshots, :force => true do |t|
      t.references :source, :polymorphic => {}
      t.references :user, :polymorphic => {}
      t.text :data
      t.timestamp :created_at
    end
    add_index :hierarchy_snapshots, [:source_id, :source_type], :name => 'source_index'
  end

  def self.down
    drop_table :hierarchy_snapshots
  end
end
