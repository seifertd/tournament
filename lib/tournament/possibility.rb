# Holds information about an Tournament::Entry's possibilities for
# remaining games in a tournament.
class Tournament::Possibility
  include Comparable
  attr_accessor :times_champ, :max_score, :min_rank
  attr_reader :champs, :entry
  def initialize(entry)
    @times_champ = 0
    @max_score = 0
    @min_rank = 1_000_000_000
    @champs = {}
    @entry = entry
  end
  def <=>(other)
    (other.times_champ <=> self.times_champ).nonzero? ||
      (self.min_rank <=> other.min_rank).nonzero? ||
      other.max_score <=> self.max_score
  end
end
