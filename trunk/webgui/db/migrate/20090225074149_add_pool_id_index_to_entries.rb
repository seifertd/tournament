class AddPoolIdIndexToEntries < ActiveRecord::Migration
  def self.up
    add_index :entries, :pool_id
  end

  def self.down
    remove_index :entries, :pool_id
  end
end
