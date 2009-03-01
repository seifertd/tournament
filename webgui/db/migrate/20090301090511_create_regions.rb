class CreateRegions < ActiveRecord::Migration
  def self.up
    create_table :regions do |t|
      t.integer :pool_id
      t.string :name
      t.integer :position
      t.timestamps
    end
  end

  def self.down
    drop_table :regions
  end
end
