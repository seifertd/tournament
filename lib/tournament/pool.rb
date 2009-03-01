# Represents a NCAA tournament pool.  Contains 4 regions
# of 16 teams each.  Champions of Region 1 and Region 2
# and champions of Region 3 and Region 4 play each
# other in the final four.
class Tournament::Pool
  attr_reader :regions  # The regions in the pool
  attr_reader :entries  # Tournament::Entry objects for participants
  attr_reader :payouts  # Hash of payouts by rank
  attr_accessor :entry_fee  # The amount each entry paid to participate
  attr_accessor :scoring_strategy  # The scoring strategy for the pool

  # Create a new empty pool with no Regions or Entries
  def initialize
    @regions = Array.new(4)
    @entries = []
    @payouts = {}
    @scoring_strategy = Tournament::ScoringStrategy::Basic.new
  end

  # add regions to the pool.  Champ of region with index = 0 plays
  # region with index = 1 and index == 2 plays index == 3.
  def add_region(name, teams, index)
    @regions[index] = {
      :name => name,
      :teams => teams
    }
  end

  # Add an Tournament::Entry object to the pool
  def add_entry(entry)
    @entries << entry
  end

  # Add an Tournament::Entry object to the pool after reading the Tournament::Entry
  # from the provided YAML file.
  def add_entry_yaml(yaml)
    @entries << YAML::load_file(yaml)
  end

  # Remove an entry by name from the pool
  def remove_by_name(name)
    entry = @entries.find {|e| e.name == name}
    if !entry.nil?
      @entries.delete(entry)
    end
  end

  # Replace existing matching entry with the provided entry
  def update_entry(entry)
    remove_by_name(entry.name)
    @entries << entry
  end

  # Set a payout.  Takes a rank (or the symbol :last for
  # last place), along with the payout.  The payout may be
  # a positive integer, in which case, it represents a 
  # percentage of the the total entry fees that particular
  # rank would receive.  The payout may also be a negative
  # integer, in which case, it represents a constant
  # payout amount.
  def set_payout(rank, payout)
    # FIXME: Add error checking
    @payouts ||= {}
    @payouts[rank] = payout
  end

  # Creates a bracket for the pool by combining all the
  # regions into one bracket of 64 teams.  By default the
  # bracket uses the basic scoring strategy.
  def bracket
    unless @bracket
      if @regions.compact.size != 4
        raise "Not all regions have been set."
      end
      all_teams = @regions.map do |region|
        region[:teams]
      end
      all_teams = all_teams.flatten
      @bracket = Tournament::Bracket.new(scoring_strategy, all_teams)
    end
    return @bracket
  end

  # Replaces the pool's bracket (as in after updating the bracket
  # for game results)
  def bracket=(new_bracket)
    @bracket = new_bracket
  end

  # Creates a Pool object for the 2008 NCAA tournament
  def self.ncaa_2008
    pool = Tournament::Pool.new
    pool.add_region("East",
      [
        Tournament::Team.new('North Carolina', 'UNC', 1),
        Tournament::Team.new('Mt. St. Mary\'s', 'MSM', 16),
        Tournament::Team.new('Indiana', 'Ind', 8),
        Tournament::Team.new('Arkansas', 'Ark', 9),
        Tournament::Team.new('Notre Dame', 'ND', 5),
        Tournament::Team.new('George Mason', 'GM', 12),
        Tournament::Team.new('Washington St.', 'WSt', 4),
        Tournament::Team.new('Winthrop', 'Win', 13),
        Tournament::Team.new('Oklahoma', 'Okl', 6),
        Tournament::Team.new('St. Joseph\'s', 'StJ', 11),
        Tournament::Team.new('Louisville', 'Lou', 3),
        Tournament::Team.new('Boise St.', 'BSt', 14),
        Tournament::Team.new('Butler', 'But', 7),
        Tournament::Team.new('South Alabama', 'SAl', 10),
        Tournament::Team.new('Tennessee', 'Ten', 2),
        Tournament::Team.new('American', 'Am', 15)
      ],
      0
    )
    pool.add_region("Midwest",
      [
        Tournament::Team.new('Kansas', 'Kan', 1),
        Tournament::Team.new('Portland St.', 'PSt', 16),
        Tournament::Team.new('UNLV', 'ULV', 8),
        Tournament::Team.new('Kent St.', 'KSt', 9),
        Tournament::Team.new('Clemson', 'Clm', 5),
        Tournament::Team.new('Villanova', 'Vil', 12),
        Tournament::Team.new('Vanderbilt', 'Van', 4),
        Tournament::Team.new('Siena', 'Sie', 13),
        Tournament::Team.new('USC', 'USC', 6),
        Tournament::Team.new('Kansas St.', 'KSU', 11),
        Tournament::Team.new('Wisconsin', 'Wis', 3),
        Tournament::Team.new('CSU Fullerton', 'CSF', 14),
        Tournament::Team.new('Gonzaga', 'Gon', 7),
        Tournament::Team.new('Davidson', 'Dav', 10),
        Tournament::Team.new('Georgetown', 'GT', 2),
        Tournament::Team.new('UMBC', 'UBC', 15)
      ],
      1
    )
    pool.add_region("South",
      [
        Tournament::Team.new('Memphis', 'Mem', 1),
        Tournament::Team.new('TX Arlington', 'TxA', 16),
        Tournament::Team.new('Mississippi St.', 'MiS', 8),
        Tournament::Team.new('Oregon', 'Ore', 9),
        Tournament::Team.new('Michigan St.', 'MSU', 5),
        Tournament::Team.new('Temple', 'Tem', 12),
        Tournament::Team.new('Pittsburgh', 'Pit', 4),
        Tournament::Team.new('Oral Roberts', 'ORo', 13),
        Tournament::Team.new('Marquette', 'Mar', 6),
        Tournament::Team.new('Kentucky', 'Ken', 11),
        Tournament::Team.new('Stanford', 'Sta', 3),
        Tournament::Team.new('Cornell', 'Cor', 14),
        Tournament::Team.new('Miami (FL)', 'Mia', 7),
        Tournament::Team.new('St. Mary\'s', 'StM', 10),
        Tournament::Team.new('Texas', 'Tex', 2),
        Tournament::Team.new('Austin Peay', 'APe', 15)
      ],
      2
    )
    pool.add_region("West",
      [
        Tournament::Team.new('UCLA', 'ULA', 1),
        Tournament::Team.new('Mis. Valley St', 'MVS', 16),
        Tournament::Team.new('BYU', 'BYU', 8),
        Tournament::Team.new('Texas A&M', 'A&M', 9),
        Tournament::Team.new('Drake', 'Dra', 5),
        Tournament::Team.new('W. Kentucky', 'WKy', 12),
        Tournament::Team.new('Connecticut', 'Con', 4),
        Tournament::Team.new('San Diego', 'SD', 13),
        Tournament::Team.new('Purdue', 'Pur', 6),
        Tournament::Team.new('Baylor', 'Bay', 11),
        Tournament::Team.new('Xavier', 'Xav', 3),
        Tournament::Team.new('Georgia', 'UG', 14),
        Tournament::Team.new('West Virginia', 'WVa', 7),
        Tournament::Team.new('Arizona', 'UA', 10),
        Tournament::Team.new('Duke', 'Duk', 2),
        Tournament::Team.new('Belmont', 'Bel', 15)
      ],
      3
    )
    return pool
  end
 
  # Run a test pool with random entries and a random outcome.
  def self.test(num_picks = 20)
    pool = ncaa_2008
    pool.entry_fee = 10
    pool.set_payout(1, 70)
    pool.set_payout(2, 20)
    pool.set_payout(3, 10)
    pool.set_payout(:last, -10)
    pool.scoring_strategy = Tournament::ScoringStrategy::Upset.new
    b = pool.bracket
    picks = (1..num_picks).map {|n| Tournament::Bracket.random_bracket(b.teams)}
    # Play out the bracket
    32.times { |n| b.set_winner(1,n+1, b.matchup(1, n+1)[rand(2)])}
    16.times { |n| b.set_winner(2,n+1, b.matchup(2, n+1)[rand(2)])}
    8.times { |n| b.set_winner(3,n+1, b.matchup(3, n+1)[rand(2)])}
    4.times { |n| b.set_winner(4,n+1, b.matchup(4, n+1)[rand(2)])}
    #2.times { |n| b.set_winner(5,n+1, b.matchup(5, n+1)[rand(2)])}
    #1.times { |n| b.set_winner(6,n+1, b.matchup(6, n+1)[rand(2)])}
    picks.each_with_index {|p, idx| pool.add_entry Tournament::Entry.new("picker_#{idx}", p) }
    picks.each_with_index do |p, idx|
      puts "Score #{idx+1}: #{p.score_against(b)}"
    end
    pool.region_report
    pool.leader_report
    pool.final_four_report
    pool.possibility_report
    pool.entry_report
    pool.score_report
  end

  # Generate the leader board report.  Shows each entry sorted by current 
  # score and gives a breakdown of score by round.
  def leader_report(out = $stdout)
    out << "Total games played: #{@bracket.games_played}" << "\n"
    out << "Number of entries: #{@entries.size}" << "\n"
    if @entries.size > 0
      out << " Curr| Max |               |Champ| Round Scores" << "\n"
      out << "Score|Score|      Name     |Live?|" + (1..bracket.rounds).to_a.map{|r| "%3d" % r}.join(" ") << "\n"
      sep ="-----+-----+---------------+-----+" + ("-" * 4 * bracket.rounds)
      out << sep << "\n"
      @entries.sort_by {|e| -e.picks.score_against(bracket)}.each do |entry|
        total = entry.picks.score_against(bracket)
        max = entry.picks.maximum_score(bracket)
        champ = entry.picks.champion
        round_scores = []
        1.upto(bracket.rounds) do |round|
          scores = entry.picks.scores_for_round(round, bracket)
          round_scores << scores.inject(0) {|sum, arr| sum += (arr[0] ? arr[0] : 0)}
        end
        out << "%5d|%5d|%15s|%3s %1s|%s" % [total, max, entry.name,
          champ.short_name,(bracket.still_alive?(champ) ? 'Y' : 'N'), round_scores.map {|s| "%3d" % s}.join(" ")] << "\n"
      end
      out << sep << "\n"
    end
  end

  # Shows detailed scores per entry.  For each pick in each game, shows
  # either a positive amount if the pick was correct, 0 if the pick was
  # incorrect, or a '?' if the game has not yet been played.
  def score_report(out = $stdout)
    # Compute scores
    out << "Total games played: #{@bracket.games_played}" << "\n"
    out << "Number of entries: #{@entries.size}" << "\n"
    sep = "-----+---------------+----------------------------------------------------------------------------------"
    if @entries.size > 0
      out << "Total|      Name     | Round Scores" << "\n"
      out << sep << "\n"
      fmt1 = "%5d|%15s|%d: %3d %s" 
      fmt2 = "     |               |%d: %3d %s" 
      fmt3 = "     |               |       %s" 
      @entries.sort_by {|e| -e.picks.score_against(bracket)}.each do |entry|
        total = entry.picks.score_against(bracket)
        1.upto(bracket.rounds) do |round|
          scores = entry.picks.scores_for_round(round, bracket)
          round_total = scores.inject(0) {|sum, arr| sum += (arr[0] ? arr[0] : 0)}
          scores_str = scores.map{|arr| "#{arr[1].short_name}=#{arr[0] ? arr[0] : '?'}"}.join(" ")
          if [1,2].include?(round)
            scores_str_arr = Tournament::Pool.split_line(scores_str, 70)
            if round == 1
              out << fmt1 % [total, entry.name, round, round_total, scores_str_arr[0]] << "\n"
            else
              out << fmt2 % [round, round_total, scores_str_arr[0]] << "\n"
            end
            scores_str_arr[1..-1].each do |scores_str|
              out << fmt3 % scores_str << "\n"
            end
          else
            out << fmt2 % [round, round_total, scores_str] << "\n"
          end
        end
        out << sep << "\n"
      end
    end
  end

  # Splits str on space chars in chunks of around len size
  def self.split_line(str, len)
    new_str = []
    beg_idx = 0
    end_idx = len - 1
    while end_idx < str.length
      end_idx += 1 while end_idx < (str.length - 1) && str[end_idx].chr != ' '
      new_str << str[beg_idx,(end_idx-beg_idx+1)].strip
      beg_idx = end_idx + 1
      end_idx += len
    end
    new_str << str[beg_idx,str.length-1]
    return new_str.reject {|s| s.nil? || s.length == 0}  
  end

  # Shows a report of each entry's picks by round.
  def entry_report(out = $stdout)
    out << "There are #{@entries.size} entries." << "\n"
    if @entries.size > 0
      out << "".center(15) + "|" + "First Round".center(128) << "\n"
      out << "Name".center(15) + "|" + "Sweet 16".center(64) + "|" + "Elite 8".center(32) +
        "|" + "Final 4".center(16) + "|" + "Final 2".center(8) + "|" + "Champion".center(15) +
        "|" + "Tie Break" << "\n"
      out << ("-" * 15) + "+" + ("-" * 64) + "+" + ("-" * 32) +
        "+" + ("-" * 16) + "+" + ("-" * 8) + "+" + ("-" * 15) +
        "+" + ("-" * 10) << "\n"
      output = Proc.new do |name, bracket, tie_breaker|
        first_round = bracket.winners[1].map {|t| "%s" % (t.short_name rescue 'Unk')}.join('-')
        sweet_16 = bracket.winners[2].map {|t| "%s" % (t.short_name rescue 'Unk')}.join('-')
        elite_8 = bracket.winners[3].map {|t| "%s" % (t.short_name rescue 'Unk')}.join('-')
        final_4 = bracket.winners[4].map {|t| "%s" % (t.short_name rescue 'Unk')}.join('-')
        final_2 = bracket.winners[5].map {|t| "%s" % (t.short_name rescue 'Unk')}.join('-')
        champ = bracket.champion.name rescue 'Unk'
        out << "               |%128s" % first_round << "\n"
        out << "%15s|%64s|%32s|%16s|%8s|%15s|%s" %
          [name, sweet_16, elite_8, final_4, final_2, champ, tie_breaker.to_s]  << "\n"
        out << ("-" * 15) + "+" + ("-" * 64) + "+" + ("-" * 32) +
          "+" + ("-" * 16) + "+" + ("-" * 8) + "+" + ("-" * 15) +
          "+" + ("-" * 10) << "\n"
      end

      output.call('Tournament', bracket, '-')

      @entries.sort_by{|e| e.name}.each do |entry|
        output.call(entry.name, entry.picks, entry.tie_breaker)
      end
    end
  end

  # Displays the regions and teams in the region.
  def region_report(out = $stdout)
    out << " Region | Seed | Team               " << "\n"
    current_idx = -1
    @regions.each_with_index do |region, idx|
      region[:teams].each do |team|
        region_name = ''
        if idx != current_idx
          region_name =  region[:name]
          current_idx = idx
          out << "--------+------+-------------------------" << "\n"
        end
        out << "%8s|%6d|%25s" % [region_name, team.seed, "#{team.name} (#{team.short_name})"] << "\n"
      end
    end
  end

  # When there are four teams left, for each of the 16 possible outcomes
  # shows who will win according to the configured payouts.
  def final_four_report(out = $stdout)
    if @entries.size == 0
      out << "There are no entries in the pool." << "\n"
      return
    end
    if self.bracket.teams_left > 4
      out << "The final four report should only be run when there" << "\n"
      out << "are four or fewer teams left in the tournament." << "\n"
      return
    end
    total_payout = @entries.size * @entry_fee
    # Subtract out constant payments
    total_payout = @payouts.values.inject(total_payout) {|t, amount| t += amount if amount < 0; t}

    payout_keys = @payouts.keys.sort do |a,b|
      if Symbol === a
        1
      elsif Symbol === b
        -1
      else
        a <=> b
      end
    end

    out << "Final Four: #{self.bracket.winners[4][0,2].map{|t| "(#{t.seed}) #{t.name}"}.join(" vs. ")}"
    out << "    #{self.bracket.winners[4][2,2].map{|t| "(#{t.seed}) #{t.name}"}.join(" vs. ")}" << "\n"
    if self.bracket.teams_left <= 2
      out << "Championship: #{self.bracket.winners[5][0,2].map{|t| "(#{t.seed}) #{t.name}"}.join(" vs. ")}" << "\n"
    end
    out << "Payouts" << "\n"
    payout_keys.each do |key|
      amount = if @payouts[key] > 0
        @payouts[key].to_f / 100.0 * total_payout
      else
        -@payouts[key]
      end
      out << "%4s: $%5.2f" % [key, amount] << "\n"
    end
    sep= "--------------+----------------+-----------------------------------------"
    out << "              |                | Winners      Tie    " << "\n"
    out << " Championship |    Champion    | Rank Score Break Name" << "\n"
    out << sep << "\n"
    self.bracket.each_possible_bracket do |poss|
      rankings = @entries.map{|p| [p, p.picks.score_against(poss)] }.sort_by {|arr| -arr[1] }
      finishers = {}
      @payouts.each do |rank, payout|
        finishers[rank] = {}
        finishers[rank][:payout] = payout
        finishers[rank][:entries] = []
        finishers[rank][:score] = 0
      end
      #puts "Got finishers: #{finishers.inspect}"
      index = 0
      rank = 1
      while index < @entries.size
        rank_score = rankings[index][1]
        finishers_key = index < (@entries.size - 1) ? rank : :last
        finish_hash = finishers[finishers_key]
        #puts "For rank_score = #{rank_score} finishers key = #{finishers_key.inspect}, hash = #{finish_hash}, index = #{index}"
        if finish_hash
          while index < @entries.size && rankings[index][1] == rank_score
            finish_hash[:entries] << rankings[index][0]
            finish_hash[:score] = rank_score
            index += 1
          end
          rank += 1
          next
        end
        index += 1
        rank += 1
      end

      num_payouts = payout_keys.size

      first_line = true
      showed_last = false
      payout_count = 0
      while payout_count < num_payouts
        rank = payout_keys[payout_count]
        finish_hash = finishers[rank]
        label = finish_hash[:entries].size == 1 ? "#{rank}".upcase : "TIE"
        finish_hash[:entries].each do |winner| 
          line = if first_line
            "%14s|%16s| %4s %5d %5d %s" % [
              poss.winners[5].map{|t| t.short_name}.join("-"),
              poss.champion.name,
              label,
              finish_hash[:score],
              winner.tie_breaker,
              winner.name
            ]
          else
            "%14s|%16s| %4s %5d %5d %s" % [
              '',
              '',
              label,
              finish_hash[:score],
              winner.tie_breaker,
              winner.name
            ]
          end
          out << line << "\n"
          first_line = false
        end
        payout_count += finish_hash[:entries].size
        showed_last = (rank == :last)
        if payout_count >= num_payouts && !showed_last
          if payout_keys[num_payouts-1] == :last
            payout_count -= 1
            showed_last = true
          end
        end
      end
      out << sep << "\n"
    end
    nil
  end

  # Runs through every possible outcome of the tournament and calculates
  # each entry's chance to win as a percentage of the possible outcomes
  # the entry would win if the tournament came out that way.
  def possibility_report(out = $stdout)
    $stdout.sync = true
    if @entries.size == 0
      out << "There are no entries in the pool." << "\n"
      return
    end
    max_possible_score = @entries.map{|p| 0}
    min_ranking = @entries.map{|p| @entries.size + 1}
    times_winner = @entries.map{|p| 0 }
    player_champions = @entries.map{|p| Hash.new {|h,k| h[k] = 0} }
    count = 0
    old_percentage = -1 
    old_remaining = 1_000_000_000_000
    out << "Checking #{self.bracket.number_of_outcomes} possible outcomes" << "\n"
    start = Time.now.to_f
    self.bracket.each_possible_bracket do |poss|
      poss_scores = @entries.map{|p| p.picks.score_against(poss)}
      sort_scores = poss_scores.sort.reverse
      @entries.each_with_index do |entry, i|
        score = poss_scores[i]
        max_possible_score[i] = score if score > max_possible_score[i]
        rank = sort_scores.index(score) + 1
        min_ranking[i] = rank if rank < min_ranking[i]
        times_winner[i] += 1 if rank == 1
        if rank == 1
          player_champions[i][poss.champion] += 1
        end
      end
      count += 1
      percentage = (count * 100.0 / self.bracket.number_of_outcomes)
      elapsed = Time.now.to_f - start
      spp = elapsed / count
      remaining = ((self.bracket.number_of_outcomes - count) * spp).to_i
      if (percentage.to_i != old_percentage) || (remaining < old_remaining)
        old_remaining = remaining
        old_percentage = percentage.to_i
        hashes = '#' * (percentage.to_i/5) + '>'
        out << "\rCalculating: %3d%% +#{hashes.ljust(20, '-')}+ %5d seconds remaining" % [percentage.to_i, remaining]
      end
    end
    out << "\n"
    #puts "\n   Max Scores: #{max_possible_score.inspect}"
    #puts "Highest Place: #{min_ranking.inspect}"
    #puts " Times Winner: #{times_winner.inspect}"
    sort_array = []
    times_winner.each_with_index { |n, i| sort_array << [n, i, min_ranking[i], max_possible_score[i], player_champions[i]] }
    sort_array = sort_array.sort_by {|arr| arr[0] == 0 ? (arr[2] == 0 ? -arr[3] : arr[2]) : -arr[0]}
    #puts "SORT: #{sort_array.inspect}"
    out << "    Entry           | Win Chance | Highest Place | Curr Score | Max Score | Tie Break  " << "\n"
    out << "--------------------+------------+---------------+------------+-----------+------------" << "\n"
    sort_array.each do |arr|
      chance = arr[0].to_f * 100.0 / self.bracket.number_of_outcomes
      out << "%19s | %10.2f | %13d | %10d | %9d | %7d " %
        [@entries[arr[1]].name, chance, min_ranking[arr[1]], @entries[arr[1]].picks.score_against(self.bracket), max_possible_score[arr[1]], @entries[arr[1]].tie_breaker] << "\n"
    end
    out << "Possible Champions For Win" << "\n"
    out << "    Entry           |    Champion     |  Ocurrences   |  Chance " << "\n"
    out << "--------------------+-----------------+---------------+---------" << "\n"
    sort_array.each do |arr|
      next if arr[4].size == 0
      arr[4].sort_by{|k,v| -v}.each_with_index do |harr, idx| 
        team = harr[0]
        occurences = harr[1]
        if idx == 0
          out << "%19s | %15s | %13d | %8.2f " % [@entries[arr[1]].name, team.name, occurences, occurences.to_f * 100.0 / arr[0]] << "\n"
        else
          out << "%19s | %15s | %13d | %8.2f " % ['', team.name, occurences, occurences.to_f * 100.0 / arr[0]] << "\n"
        end
      end
      out << "--------------------+-----------------+---------------+---------" << "\n"
    end
    nil
  end

end
