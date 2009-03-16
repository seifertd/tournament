# Module namespace for various scoring strategies for 
# tournament pools.
module Tournament::ScoringStrategy

  # Class representing a scoring strategy where correct picks
  # are worth 2 X the round number
  class Basic
    def score(pick, winner, loser, round)
      winner != Tournament::Bracket::UNKNOWN_TEAM && pick == winner ? round * 2 : 0
    end
    def name
      'Basic'
    end
    def description
      "Each correct pick is worth 2 times the round number."
    end
  end

  # Class representing a scoring strategy where correct picks
  # are worth 1 point each, regardless of round
  class ConstantValue
    def score(pick, winner, loser, round)
      winner != Tournament::Bracket::UNKNOWN_TEAM && pick == winner ? 1 : 0
    end
    def name
      'Constant Value'
    end
    def description
      "Each correct pick is worth 1 point, regardless of the round."
    end
  end

  # Class representing a scoring strategy where correct picks
  # are worth a base amount per round (3, 5, 11, 19, 30 and 40)
  # plus the seed number of the winner.
  class Upset
    PER_ROUND = [3, 5, 11, 19, 30, 40]
    def score(pick, winner, loser, round)
      if winner != Tournament::Bracket::UNKNOWN_TEAM && pick == winner
        return PER_ROUND[round-1] + winner.seed
      end
      return 0
    end
    def name
      'Upset'
    end
    def description
      "Each correct pick is worth #{PER_ROUND.join(', ')} per round plus the seed number of the winning team."
    end
  end

  # Class representing a scoring strategy where correct picks are
  # worth the seed number of the winner times a per round 
  # multiplier (1,2,4,8,16,32)
  class JoshPatashnik
    MULTIPLIERS = [1, 2, 4, 8, 16, 32]
    def score(pick, winner, loser, round)
       if winner != Tournament::Bracket::UNKNOWN_TEAM && pick == winner
          return MULTIPLIERS[round-1] * winner.seed
       end
       return 0
    end
    def name
      'Josh Patashnik'
    end
    def description
      "Each correct pick is worth the seed number of the winning team times a per round multiplier: #{MULTIPLIERS.join(', ')}"
    end
  end

  # Class representing a scoring strategy where correct picks are
  # worth the seed number of the winner times a per round 
  # multiplier (1,2,4,8,12,22)
  class TweakedJoshPatashnik
    MULTIPLIERS = [1, 2, 4, 8, 12, 22]
    def score(pick, winner, loser, round)
       if winner != Tournament::Bracket::UNKNOWN_TEAM && pick == winner
          return MULTIPLIERS[round-1] * winner.seed
       end
       return 0
    end
    def name
      'Tweaked Josh Patashnik'
    end
    def description
      "Each correct pick is worth the seed number of the winning team times a per round multiplier: #{MULTIPLIERS.join(', ')}"
    end
  end

  # Returns names of available strategies.  The names returned are suitable
  # for use in the strategy_for_name method
  def self.available_strategies
    return ['basic', 'upset', 'josh_patashnik', 'tweaked_josh_patashnik', 'constant_value]
  end

  # Returns an instantiated strategy class for the named strategy.
  def self.strategy_for_name(name)
    clazz = Tournament::ScoringStrategy.const_get(name.capitalize.gsub(/_([a-zA-Z])/) {|m| $1.upcase})
    return clazz.new
  end

end
