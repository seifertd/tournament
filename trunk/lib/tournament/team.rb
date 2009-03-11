# Represents a team in a tournament Bracket
class Tournament::Team
  attr_reader :name, :short_name, :seed
  
  def initialize(name, short_name, seed)
    @name = name
    @short_name = short_name
    @seed = seed
  end

  def ==(other)
    return false unless Tournament::Team === other
    @name == other.name && @short_name == other.short_name && @seed == other.seed
  end

  def eql?(other)
    @name.eql?(other)
  end
end
