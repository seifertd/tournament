class AddTieBreakToEntry < ActiveRecord::Migration
  def self.up
    add_column :entries, :tie_break, :integer
  end

  def self.down
    remove_column :entries, :tie_break
  end
end
