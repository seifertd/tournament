# Class representing an entry in a pool.
class Tournament::Entry
  attr_accessor :name   # Name of the entry
  attr_accessor :picks  # The entry picks as a Tournament::Bracket object
  attr_accessor :tie_breaker  # The tie breaker object

  # Create a new entry
  def initialize(name = nil, picks = nil, tie_breaker = 100)
    @name = name
    @picks = picks
    @tie_breaker = tie_breaker
  end

  # Alias picks as bracket
  alias_method :bracket, :picks
end
