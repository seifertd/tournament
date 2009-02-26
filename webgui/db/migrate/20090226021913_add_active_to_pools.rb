class AddActiveToPools < ActiveRecord::Migration
  def self.up
    add_column :pools, :active, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :pools, :active
  end
end
