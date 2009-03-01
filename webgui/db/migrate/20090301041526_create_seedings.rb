class CreateSeedings < ActiveRecord::Migration
  def self.up
    create_table :seedings do |t|
      t.integer :pool_id
      t.integer :team_id
      t.string :region
      t.integer :seed

      t.timestamps
    end
  end

  def self.down
    drop_table :seedings
  end
end
