class Entry < ActiveRecord::Base
  belongs_to :user
  validates_uniqueness_of :name
  validates_presence_of :tie_break
  validates_presence_of :user_id

  # Override bracket to resolve the db blob to an object
  def bracket
    @bracket ||= if self[:bracket]
      Marshal.load(self[:bracket])
    else
      Tournament::Bracket.new($pool.bracket.teams)
    end
  end

  def before_save
    self[:bracket] = Marshal.dump(@bracket)
  end

  def tournament_entry
    @tournament_entry ||= Tournament::Entry.new(self.name, self.bracket, self.tie_break)
  end
end
