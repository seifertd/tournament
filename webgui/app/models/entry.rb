class Entry < ActiveRecord::Base
  belongs_to :user
  belongs_to :pool
  validates_uniqueness_of :name
  validates_presence_of :tie_break
  validates_presence_of :user_id

  # Override bracket to resolve the db blob to an object
  def bracket
    unless @bracket
      if self[:data]
        @bracket = Marshal.load(self[:data])
      end
      @bracket ||= Tournament::Bracket.new(self.pool.scoring_strategy, self.pool.pool.bracket.teams)
    end
    @bracket
  end

  def reset
    @bracket = Tournament::Bracket.new(self.pool.scoring_strategy, self.pool.pool.bracket.teams)
  end

  def before_save
    if @bracket
      logger.debug("MARSHALLING BRACKET: #{@bracket.inspect}")
      self[:data] = Marshal.dump(@bracket)
      logger.debug("DONE MARSHALLING BRACKET")
    end
  end

  def after_save
    if self.bracket.complete? && self.bracket.user_id != self.pool.user_id
      self.pool.pool.update_entry(self.tournament_entry)
      self.pool.save!
    end
  end

  def tournament_entry
    @tournament_entry ||= Tournament::Entry.new(self.name, self.bracket, self.tie_break)
  end

end
