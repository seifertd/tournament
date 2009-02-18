class AddPostitionToRoles < ActiveRecord::Migration
  def self.up
    add_column :roles, :position, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :roles, :position
  end
end
