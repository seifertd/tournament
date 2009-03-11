class AddUserIdToPool < ActiveRecord::Migration
  def self.up
    add_column :pools, :user_id, :integer
  end

  def self.down
    remove_column :pools, :user_id
  end
end
