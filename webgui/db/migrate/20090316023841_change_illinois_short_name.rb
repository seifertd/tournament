class ChangeIllinoisShortName < ActiveRecord::Migration
  def self.up
    t = Team.find_by_name("Illinois")
    if t
      t.short_name = "Ill"
      t.save!
    end
  end

  def self.down
    # Not reversible
  end
end
