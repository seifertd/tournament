# Class representing a bracket in a tournament.
class Tournament::Bracket
  attr_reader :name  # The name of the bracket
  attr_reader :teams # The teams in the bracket
  attr_reader :rounds # The number of rounds in the bracket
  attr_reader :winners # The winners of each game in the bracket
  attr_reader :scoring_strategy # The strategy used to assign points to correct picks


  UNKNOWN_TEAM = :unk unless defined?(UNKNOWN_TEAM)

  # Creates a new bracket with the given teams
  def initialize(scoring_strategy, teams = nil)
    @teams = teams || [:t1, :t2, :t3, :t4, :t5, :t6, :t7, :t8, :t9, :t10, :t11, :t12, :t13, :t14, :t15, :t16]
    @rounds = (Math.log(@teams.size)/Math.log(2)).to_i
    @winners = [@teams] + (1..@rounds).map do |r|
      [UNKNOWN_TEAM] * games_in_round(r)
    end
    @scoring_strategy = scoring_strategy
  end

  # Returns true if the provided team has not lost
  def still_alive?(team)
    return false if team == UNKNOWN_TEAM
    team_index = @winners[0].index(team)
    game = team_index/2
    round = 1
    #puts "Checking round #{round} game #{game} winner #{@winners[round][game].inspect} team #{team.short_name}"
    while @winners[round][game] == team && round < self.rounds
      round += 1
      game /= 2
      #puts "Checking round #{round} game #{game} winner #{@winners[round][game].inspect} team #{team.short_name}"
    end
    return [UNKNOWN_TEAM, team].include?(@winners[round][game])
  end

  # Returns the number of games that have been decided in the bracket
  def games_played
    @winners[1..-1].inject(0) { |sum, arr| sum += arr.inject(0) {|sum2, t| sum2 += (t != UNKNOWN_TEAM ? 1 : 0) } }
  end

  # For each possible outcome remaining in the pool, generates a bracket representing
  # that outcome and yields it to the caller's block.  This can take a very long time
  # with more than about 22 teams left.
  def each_possible_bracket
    puts "WARNING: This is likely going to take a very long time ... " if teams_left > 21
    each_possibility do |possibility|
      yield(bracket_for(possibility))
    end
  end

  # Returns the number of rounds that have been completed
  def number_rounds_complete
    round = 0
    while round < self.rounds
      break if @winners[round+1].any? {|t| t == UNKNOWN_TEAM}
      round += 1
    end
    return round  
  end

  # Returns true if all games have been decided
  def complete?
    round = 0
    while round < self.rounds
      return false if @winners[round+1].any? {|t| t == UNKNOWN_TEAM}
      round += 1
    end
    return true
  end

  # Returns the number of teams left in the bracket.
  def teams_left
    return 1 + @winners.inject(0) { |memo, arr| arr.inject(memo) {|memo, team| memo += (team == UNKNOWN_TEAM ? 1 : 0)} }
  end

  # Returns the number of possible outcomes for the bracket
  def number_of_outcomes
    @number_of_outcomes ||= (2 ** (self.teams_left)) / 2
  end

  # Iterates over each possiblity by representing the possibility as a binary number and
  # yielding each number to the caller's block.  The binary number is formed
  # by assuming each game is a bit.  If the first team in the matchup wins, the
  # bit is set to 0.  If the second team in the matchup wins, the bit is set to
  # 1.  repeat for each round and the entire bracket result can be represented.
  # As an example, consider a 8 team bracket:
  #
  #   Round 0:    t1  t2    t3  t4   t5  t6    t7  t8    Bits 
  #         1:      t1        t4       t6        t7     0 1 1 0   
  #         2:           t4                 t6            1 0
  #         3:                    t6                       1 
  #
  #   final binary number: 0110101
  #
  # If no games have been played, we can represent each possibility
  # by every possible 7 bit binary number.
  def each_possibility
    # bit masks of games that have been played
    # played_mask is for any game where a winner has been determined
    # first is a mask where the first of the matched teams won
    # second is a mask where the second of the matched teams won
    shift = 0
    round = @rounds
    played_mask, winners, left_mask = @winners[1..-1].reverse.inject([0,0,0]) do |masks, round_winners|
      game = games_in_round(round)
      round_winners.reverse.each do |game_winner|
        #puts "checking matchup of round #{round} game #{game} winner #{game_winner} matchup #{matchup(round,game)}"
        val = 1 << shift
        if UNKNOWN_TEAM != game_winner
          # played mask
          masks[0] = masks[0] | val
          # winners mask
          if matchup(round,game).index(game_winner) == 1
            masks[1] = masks[1] | val
          end
        else
          # games left mask
          masks[2] = masks[2] | val
        end
        shift += 1
        game -= 1
      end
      round -= 1
      masks
    end
    #puts "played mask: #{Tournament::Bracket.jbin(played_mask, teams.size - 1)}"
    #puts "  left mask: #{Tournament::Bracket.jbin(left_mask, teams.size - 1)} #{left_mask}"
    #puts "    winners: #{Tournament::Bracket.jbin(winners, teams.size - 1)}"

    # for the games left mask, figure out which bits are 1 and what
    # their index is.  If left mask is 1001, the shifts array would be
    # [0, 3].  If left mask is 1111, the shifts array would be
    # [0, 1, 2, 3]
    count = 0
    shifts = []
    Tournament::Bracket.jbin(left_mask, teams.size - 1).reverse.split('').each do |c|
      if c == '1'
        shifts << count
      end
      count += 1
    end

    #puts "    shifts: #{shifts.inspect}"

    # Figure out the number of possibilities.  This is simply
    # 2 ** shifts.size
    num_possibilities = 2 ** shifts.size
    #num_possibilities = 0
    #shifts.size.times { |n| num_possibilities |= (1 << n) }

    #puts "Checking #{num_possibilities} (#{number_of_outcomes}) possible outcomes."
    possibility = num_possibilities - 1
    while possibility >= 0
      #puts "    possibility: #{Tournament::Bracket.jbin(possibility, teams.size - 1)}"
      real_poss = 0
      shifts.each_with_index do |s, i|
        real_poss |= (((possibility & (1 << i)) > 0 ? 1 : 0) << s)
      end
      #puts "    real_poss: #{Tournament::Bracket.jbin(real_poss, teams.size - 1)}"
      real_poss = winners | real_poss
      #puts "    real_poss: #{Tournament::Bracket.jbin(real_poss, teams.size - 1)}"
      yield(real_poss)
      possibility -= 1
    end
  end

  # Given a binary possibility number, compute the bracket
  # that would result.
  def bracket_for(possibility)
    pick_bracket = Tournament::Bracket.new(self.scoring_strategy, self.teams)
    round = 1
    while round <= pick_bracket.rounds
      gir = pick_bracket.games_in_round(round)
      game = 1
      while game <= gir
        matchup = pick_bracket.matchup(round, game)
        mask = 1 << (gir - game)
        # Shift for round
        mask = mask << (2 ** (pick_bracket.rounds - round) - 1)
        pick = (mask & possibility) > 0 ? 1 : 0
        #puts "round #{round} game #{game} mask #{Tournament::Bracket.jbin(mask)} poss: #{Tournament::Bracket.jbin(possibility)} pick #{pick} winner #{matchup[pick]}"
        pick_bracket.set_winner(round, game, matchup[pick])
        game += 1
      end
      round += 1
    end
    return pick_bracket
  end

  # Returns a two element array containing the Teams in the
  # matchup for the given round and game
  def matchup(round, game)
    return @winners[round-1][(game-1)*2..(game-1)*2+1]
  end

  # Returns true if the given team was the winner of the
  # round and game
  def pick_correct(round, game, team)
    return team != UNKNOWN_TEAM && team == winner(round, game)
  end

  # Returns the number of games in the given round
  def games_in_round(round)
    return @teams.size / 2 ** round
  end

  # Returns the winner of the given round and game
  def winner(round, game)
    return @winners[round][game-1]
  end

  # Returns a two element array whose first element is the winner
  # and the second element is the loser of the given round and game
  def winner_and_loser(round, game)
    winner = winner(round,game)
    if UNKNOWN_TEAM == winner
      return [UNKNOWN_TEAM, UNKNOWN_TEAM]
    end
    matchup = matchup(round, game)
    if matchup[0] == winner
      return matchup
    else
      return matchup.reverse
    end
  end

  # Given a overall game number, return the round and round game number
  def round_and_game(overall_game)
    1.upto(rounds) do |r|
      if overall_game <= games_in_round(r)
        return [r, overall_game]
      else
        overall_game -= games_in_round(r)
      end
    end
  end

  # Sets the winner of the given round and game to the provided team
  def set_winner(round, game, team)
    if UNKNOWN_TEAM == team || matchup(round, game).include?(team)
      @winners[round][game-1] = team
      @number_of_outcomes = nil
    else
      raise "Round #{round}, Game #{game} matchup does not include team #{team.inspect}"
    end
  end

  # Pretty print.
  def inspect
    str = ""
    1.upto(rounds) do |r| str << "round #{r}: games: #{games_in_round(r)}: matchups: #{(1..games_in_round(r)).map{|g| matchup(r,g)}.inspect}\n" end
    str << "Champion: #{champion.inspect}"
    return str
  end

  # Returns the champion of this bracket
  def champion
    return @winners[@rounds][0]
  end

  # Compute the maximum possible score if all remaining picks in this 
  # bracket turn out to be correct.
  def maximum_score(other_bracket)
    score = 0
    round = 1
    while round <= self.rounds
      games_in_round = self.games_in_round(round)
      game = 1
      while game <= games_in_round
        winner, loser = other_bracket.winner_and_loser(round, game)
        pick = self.winner(round, game)
        winner = pick if winner == UNKNOWN_TEAM && other_bracket.still_alive?(pick)
        score += other_bracket.scoring_strategy.score(pick, winner, loser, round)
        game += 1
      end
      round += 1
    end
    return score
  end

  # Computes the total score of this bracket using other_bracket
  # as the guide
  def score_against(other_bracket)
    score = 0
    round = 1
    while round <= self.rounds
      games_in_round = self.games_in_round(round)
      game = 1
      while game <= games_in_round
        winner, loser = other_bracket.winner_and_loser(round, game)
        score += other_bracket.scoring_strategy.score(self.winner(round, game), winner, loser, round)
        #puts "round #{round} game #{game} winner #{winner} loser #{loser} pick #{self.winner(round,game)}"
        game += 1
      end
      round += 1
    end
    return score
  end

  # Compute the score for a particular round against the other_bracket
  # Returns an array of two element arrays, one for each game in the
  # round.  The first element of the subarray is the score and the
  # second element is the team that was picked.  If the winner of the 
  # game is unknown (because it has not been played), the score element
  # will be nil.
  def scores_for_round(round, other_bracket)
    games_in_round = self.games_in_round(round)
    return (1..games_in_round).to_a.map do |g|
      winner, loser = other_bracket.winner_and_loser(round, g)
      pick = self.winner(round, g)
      score = nil
      if winner != UNKNOWN_TEAM || !other_bracket.still_alive?(pick)
        score = other_bracket.scoring_strategy.score(pick, winner, loser, round)
      end
      [score, pick]
    end
  end

  # Generates a bracket for the provided teams with a random winner
  # for each game.
  def self.random_bracket(teams = nil)
    b = Tournament::Bracket.new(Tournament::ScoringStrategy::Basic.new, teams)
    1.upto(b.rounds) do |r|
      1.upto(b.games_in_round(r)) { |g| b.set_winner(r, g, b.matchup(r, g)[rand(2)]) }
    end
    return b
  end

  private

  def self.jbin(num, size = 8)
    return num.to_s(2).rjust(size, '0')
  end

end
