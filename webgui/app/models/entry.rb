class Entry < ActiveRecord::Base
  belongs_to :user
  validates_uniqueness_of :name
  validates_presence_of :tie_break
  validates_presence_of :user_id
  after_save :update_pool_entry

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

  def update_pool_entry
    return if self.name == "Tournament Bracket"
    return if !self.bracket.complete?
    # TODO: Make this safe (Pool saved in db)
    $pool.update_entry(self.tournament_entry)
    Tournament.save_pool
  end
end
