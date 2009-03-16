class Entry < ActiveRecord::Base
  belongs_to :user
  belongs_to :pool
  validates_uniqueness_of :name
  validates_presence_of :tie_break
  validates_presence_of :user_id
  attr_accessor :old_name

  # Override bracket to resolve the db blob to an object
  def bracket
    unless @bracket
      if self[:data]
        @bracket = Marshal.load(self[:data])
      end
      @bracket ||= Tournament::Bracket.new(self.pool.pool.tournament_entry.picks.teams)
    end
    @bracket
  end

  def reset
    @bracket = Tournament::Bracket.new(self.pool.pool.tournament_entry.picks.teams)
  end

  def before_save
    if @bracket
      logger.debug("MARSHALLING BRACKET: #{@bracket.inspect}")
      self[:data] = Marshal.dump(@bracket)
      logger.debug("DONE MARSHALLING BRACKET")
    end
  end

  def after_save
    if self.bracket.complete? && self.user_id != self.pool.user_id
      if self.old_name
        # We changed entry names, so pull the old one out of the
        # backing pool
        self.pool.pool.entries.delete_if{|e| self.old_name == e.name}
      end
      self.pool.pool.update_entry(self.tournament_entry)
      self.pool.save!
    end
  end

  # Override name= to record name changes
  def name=(new_name)
    if new_name != self.name
      self.old_name = self.name
      self.write_attribute(:name, new_name)
    end
  end

  def tournament_entry
    @tournament_entry ||= Tournament::Entry.new(self.name, self.bracket, self.tie_break)
  end

end
