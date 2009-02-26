class RenameBracketColumnToData < ActiveRecord::Migration
  def self.up
    rename_column :entries, :bracket, :data
  end

  def self.down
    rename_column :entries, :data, :bracket
  end
end
