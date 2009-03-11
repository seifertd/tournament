class RelateEntryAndUser < ActiveRecord::Migration
  def self.up
    add_column :entries, :user_id, :integer, :null => false, :default => 1
    add_index :entries, :user_id
  end

  def self.down
    remove_column :entries, :user_id
  end
end
