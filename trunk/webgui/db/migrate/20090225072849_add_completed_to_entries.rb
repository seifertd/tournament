class AddCompletedToEntries < ActiveRecord::Migration
  def self.up
    add_column :entries, :completed, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :entries, :completed
  end
end
