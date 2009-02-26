class AssociatePoolAndEntry < ActiveRecord::Migration
  def self.up
    add_column :entries, :pool_id, :integer
  end

  def self.down
    remove_column :entries, :pool_id
  end
end
