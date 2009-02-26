class CreatePools < ActiveRecord::Migration
  def self.up
    create_table :pools do |t|
      t.string :name, :null => false
      t.text :data
      t.boolean :started, :null => false, :default => false
      t.datetime :starts_at

      t.timestamps
    end
  end

  def self.down
    drop_table :pools
  end
end
