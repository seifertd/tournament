class CreateEntries < ActiveRecord::Migration
  def self.up
    create_table :entries do |t|
      t.column :name, :string, :limit => 64, :null => false
      t.column :bracket, :blob
      t.timestamps
    end
  end

  def self.down
    drop_table :entries
  end
end
