class ChangePoolDataColumn < ActiveRecord::Migration
  def self.up
    change_column :pools, :data, :blob
  end

  def self.down
    change_column :pools, :data, :text
  end
end
