# Represents a NCAA tournament pool.  Contains 4 regions
# of 16 teams each.  Champions of Region 1 and Region 2
# and champions of Region 3 and Region 4 play each
# other in the final four.
class Tournament::Pool
  # The regions in the pool.
  attr_reader :regions
  # Tournament::Entry objects for the participants
  attr_reader :entries
  # Hash of payouts by rank
  attr_reader :payouts
  # The entry fee
  attr_accessor :entry_fee
  # The scoring strategy for the pool
  attr_reader :scoring_strategy

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

  # Set new scoring strategy.  This should not be allowed.
  def scoring_strategy=(new_strat)
    @scoring_strategy = new_strat
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

  # Creates a entry for the pool by combining all the
  # regions into one bracket of 64 teams.  By default the
  # entry bracket uses the basic scoring strategy.
  def tournament_entry
    unless @tournament_entry
      if @regions.compact.size != 4
        raise "Not all regions have been set."
      end
      all_teams = @regions.map do |region|
        region[:teams]
      end
      all_teams = all_teams.flatten
      bracket = Tournament::Bracket.new(all_teams)
      @tournament_entry = Tournament::Entry.new('Tournament Entry', bracket, nil)
    end
    return @tournament_entry
  end

  # Replaces the pool's bracket (as in after updating the bracket
  # for game results)
  def tournament_entry=(new_entry)
    @tournament_entry = new_entry
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
 
  # Creates a Pool object for the 2009 NCAA tournament
  def self.ncaa_2009
    pool = Tournament::Pool.new
    pool.add_region("Midwest",
      [
        Tournament::Team.new('Louisville', 'UNC', 1),
        Tournament::Team.new('Morehead State', 'MrS', 16),
        Tournament::Team.new('Ohio State', 'OSU', 8),
        Tournament::Team.new('Siena', 'Sie', 9),
        Tournament::Team.new('Utah', 'Uta', 5),
        Tournament::Team.new('Arizona', 'UA', 12),
        Tournament::Team.new('Wake Forest', 'WkF', 4),
        Tournament::Team.new('Cleveland State', 'ClS', 13),
        Tournament::Team.new('West Virginia', 'WVa', 6),
        Tournament::Team.new('Dayton', 'Day', 11),
        Tournament::Team.new('Kansas', 'Kan', 3),
        Tournament::Team.new('North Dakota State', 'NDS', 14),
        Tournament::Team.new('Boston College', 'BC', 7),
        Tournament::Team.new('USC', 'USC', 10),
        Tournament::Team.new('Michigan State', 'MSU', 2),
        Tournament::Team.new('Robert Morris', 'RbM', 15)
      ],
      0
    )
    pool.add_region("West",
      [
        Tournament::Team.new('Connecticut', 'Con', 1),
        Tournament::Team.new('Chattanooga', 'Cht', 16),
        Tournament::Team.new('BYU', 'BYU', 8),
        Tournament::Team.new('Texas A&M', 'A&M', 9),
        Tournament::Team.new('Purdue', 'Pur', 5),
        Tournament::Team.new('Northern Iowa', 'NIo', 12),
        Tournament::Team.new('Washington', 'Was', 4),
        Tournament::Team.new('Mississippi State', 'MiS', 13),
        Tournament::Team.new('Marquette', 'Mar', 6),
        Tournament::Team.new('Utah State', 'USt', 11),
        Tournament::Team.new('Missouri', 'Msr', 3),
        Tournament::Team.new('Cornell', 'Cor', 14),
        Tournament::Team.new('California', 'Cal', 7),
        Tournament::Team.new('Maryland', 'Mry', 10),
        Tournament::Team.new('Memphis', 'Mem', 2),
        Tournament::Team.new('Cal State Northridge', 'CSN', 15)
      ],
      1
    )
    pool.add_region("East",
      [
        Tournament::Team.new('Pittsburgh', 'Pit', 1),
        Tournament::Team.new('East Tennessee State', 'ETS', 16),
        Tournament::Team.new('Oklahoma State', 'OkS', 8),
        Tournament::Team.new('Tennessee', 'Ten', 9),
        Tournament::Team.new('Florida State', 'FSU', 5),
        Tournament::Team.new('Wisconsin', 'Wis', 12),
        Tournament::Team.new('Xavier', 'Xav', 4),
        Tournament::Team.new('Portland St', 'PSt', 13),
        Tournament::Team.new('UCLA', 'ULA', 6),
        Tournament::Team.new('Virginia Commonwealth', 'VAC', 11),
        Tournament::Team.new('Villanova', 'Vil', 3),
        Tournament::Team.new('Cornell', 'Cor', 14),
        Tournament::Team.new('Texas', 'Tex', 7),
        Tournament::Team.new('Minnesota', 'Min', 10),
        Tournament::Team.new('Duke', 'Duk', 2),
        Tournament::Team.new('Binghamton', 'Bin', 15)
      ],
      2
    )
    pool.add_region("South",
      [
        Tournament::Team.new('North Carolina', 'UNC', 1),
        Tournament::Team.new('Radford', 'Rad', 16),
        Tournament::Team.new('LSU', 'LSU', 8),
        Tournament::Team.new('Butler', 'But', 9),
        Tournament::Team.new('Illinois', 'Ill', 5),
        Tournament::Team.new('W. Kentucky', 'WKy', 12),
        Tournament::Team.new('Gonzaga', 'Gon', 4),
        Tournament::Team.new('Akron', 'Akr', 13),
        Tournament::Team.new('Arizona State', 'ASU', 6),
        Tournament::Team.new('Temple', 'Tem', 11),
        Tournament::Team.new('Syracuse', 'Syr', 3),
        Tournament::Team.new('Stephen F. Austin', 'SFA', 14),
        Tournament::Team.new('Clemson', 'Cle', 7),
        Tournament::Team.new('Michigan', 'UM', 10),
        Tournament::Team.new('Oklahoma', 'Okl', 2),
        Tournament::Team.new('Morgan State', 'MgS', 15)
      ],
      3
    )
    return pool
  end
 
  # Creates a Pool object for the 2010 NCAA tournament
  def self.ncaa_2010
    pool = Tournament::Pool.new
    pool.add_region("Midwest",
      [
        Tournament::Team.new('Kansas', 'Kan', 1),
        Tournament::Team.new('Lehigh', 'Leh', 16),
        Tournament::Team.new('UNLV', 'ULV', 8),
        Tournament::Team.new('Northern Iowa', 'NIo', 9),
        Tournament::Team.new('Michigan St.', 'MSU', 5),
        Tournament::Team.new('New Mexico State', 'NMS', 12),
        Tournament::Team.new('Maryland', 'Mry', 4),
        Tournament::Team.new('Houston', 'Hou', 13),
        Tournament::Team.new('Tennessee', 'Ten', 6),
        Tournament::Team.new('San Diego State', 'SDS', 11),
        Tournament::Team.new('Georgetown', 'GT', 3),
        Tournament::Team.new('Ohio', 'Ohi', 14),
        Tournament::Team.new('Oklahoma State', 'OkS', 7),
        Tournament::Team.new('Georgia Tech', 'GTc', 10),
        Tournament::Team.new('Ohio State', 'OSU', 2),
        Tournament::Team.new('UC Santa Barbara', 'SB', 15)
      ],
      0
    )
    pool.add_region("West",
      [
        Tournament::Team.new('Syracuse', 'Syr', 1),
        Tournament::Team.new('Vermont', 'Ver', 16),
        Tournament::Team.new('Gonzaga', 'Gon', 8),
        Tournament::Team.new('Florida State', 'FSU', 9),
        Tournament::Team.new('Butler', 'But', 5),
        Tournament::Team.new('UTEP', 'UTP', 12),
        Tournament::Team.new('Vanderbilt', 'Van', 4),
        Tournament::Team.new('Murray State', 'Mur', 13),
        Tournament::Team.new('Xavier', 'Xav', 6),
        Tournament::Team.new('Minnesota', 'Min', 11),
        Tournament::Team.new('Pittsburgh', 'Pit', 3),
        Tournament::Team.new('Oakland', 'Oak', 14),
        Tournament::Team.new('BYU', 'BYU', 7),
        Tournament::Team.new('Florida', 'Fla', 10),
        Tournament::Team.new('Kansas St.', 'KSU', 2),
        Tournament::Team.new('Nort Texas', 'NTx', 15)
      ],
      1
    )
    pool.add_region("East",
      [
        Tournament::Team.new('Kentucky', 'Ken', 1),
        Tournament::Team.new('East Tennessee State', 'ETS', 16),
        Tournament::Team.new('Texas', 'Tex', 8),
        Tournament::Team.new('Wake Forest', 'WkF', 9),
        Tournament::Team.new('Temple', 'Tem', 5),
        Tournament::Team.new('Cornell', 'Cor', 12),
        Tournament::Team.new('Wisconsin', 'Wis', 4),
        Tournament::Team.new('Wofford', 'Wof', 13),
        Tournament::Team.new('Marquette', 'Mar', 6),
        Tournament::Team.new('Washington', 'Was', 11),
        Tournament::Team.new('New Mexico', 'NMx', 3),
        Tournament::Team.new('Montana', 'Mon', 14),
        Tournament::Team.new('Clemson', 'Clm', 7),
        Tournament::Team.new('Missouri', 'Msr', 10),
        Tournament::Team.new('West Virginia', 'WVa', 2),
        Tournament::Team.new('Morgan State', 'MgS', 15)
      ],
      2
    )
    pool.add_region("South",
      [
        Tournament::Team.new('Duke', 'Duk', 1),
        Tournament::Team.new('Arkansa-Pine Bluff', 'APB', 16),
        Tournament::Team.new('California', 'Cal', 8),
        Tournament::Team.new('Louisville', 'Lou', 9),
        Tournament::Team.new('Texas A&M', 'A&M', 5),
        Tournament::Team.new('Utah State', 'USt', 12),
        Tournament::Team.new('Purdue', 'Pur', 4),
        Tournament::Team.new('Siena', 'Sie', 13),
        Tournament::Team.new('Notre Dame', 'ND', 6),
        Tournament::Team.new('Old Dominion', 'OD', 11),
        Tournament::Team.new('Baylor', 'Bay', 3),
        Tournament::Team.new('Sam Houston State', 'SHS', 14),
        Tournament::Team.new('Richmond', 'Rch', 7),
        Tournament::Team.new("St. Mary's", 'StM', 10),
        Tournament::Team.new('Villanova', 'Vil', 2),
        Tournament::Team.new('Robert Morris', 'RbM', 15)
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
    b = pool.tournament_entry.picks
    picks = (1..num_picks).map {|n| Tournament::Bracket.random_bracket(b.teams)}
    # Play out the bracket
    32.times { |n| b.set_winner(1,n+1, b.matchup(1, n+1)[rand(2)])}
    #16.times { |n| b.set_winner(2,n+1, b.matchup(2, n+1)[rand(2)])}
    #2.times { |n| b.set_winner(3,n+1, b.matchup(3, n+1)[rand(2)])}
#4.times { |n| b.set_winner(4,n+1, b.matchup(4, n+1)[rand(2)])}
    #2.times { |n| b.set_winner(5,n+1, b.matchup(5, n+1)[rand(2)])}
    #1.times { |n| b.set_winner(6,n+1, b.matchup(6, n+1)[rand(2)])}
    picks.each_with_index {|p, idx| pool.add_entry Tournament::Entry.new("picker_#{idx}", p) }
    picks.each_with_index do |p, idx|
      puts "Score #{idx+1}: #{p.score_against(b, pool.scoring_strategy)}"
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
    out << "Total games played: #{tournament_entry.picks.games_played}" << "\n"
    if tournament_entry.picks.complete?
      out << "Champion: #{tournament_entry.picks.champion.name}" << "\n"
    end
    out << "Pool Tie Break: #{tournament_entry.tie_breaker || '-'}" << "\n"
    out << "Number of entries: #{@entries.size}" << "\n"
    current_rank = 1
    if @entries.size > 0
      out << "    | Curr| Max |               |Champ| Tie | Round Scores" << "\n"
      out << "Rank|Score|Score|      Name     |Live?|Break|" + (1..tournament_entry.picks.rounds).to_a.map{|r| "%3d" % r}.join(" ") << "\n"
      sep ="----+-----+-----+---------------+-----+-----+" + ("-" * 4 * tournament_entry.picks.rounds)
      out << sep << "\n"
      @entries.sort do |e1, e2|
        s1 = e1.picks.score_against(tournament_entry.picks, self.scoring_strategy)
        s2 = e2.picks.score_against(tournament_entry.picks, self.scoring_strategy)
        if s1 == s2 && tournament_entry.tie_breaker
          s1 = 0 - (e1.tie_breaker - tournament_entry.tie_breaker).abs
          s2 = 0 - (e2.tie_breaker - tournament_entry.tie_breaker).abs
        end
        s2 <=> s1
      end.inject(nil) do |last_entry, entry|
        total = entry.picks.score_against(tournament_entry.picks, self.scoring_strategy)
        max = entry.picks.maximum_score(tournament_entry.picks, self.scoring_strategy)
        champ = entry.picks.champion
        round_scores = []
        1.upto(tournament_entry.picks.rounds) do |round|
          scores = entry.picks.scores_for_round(round, tournament_entry.picks, self.scoring_strategy)
          round_scores << scores.inject(0) {|sum, arr| sum += (arr[0] ? arr[0] : 0)}
        end
        rank_display = nil
        if last_entry && !tournament_entry.tie_breaker && total == last_entry.bracket.score_against(tournament_entry.picks, self.scoring_strategy)
          rank_display = 'TIE'
        else
          rank_display = "%4d" % current_rank
        end
        out << "%4s|%5d|%5d|%15s|%3s %1s|%5d|%s" % [rank_display, total, max, entry.name,
          champ.short_name,(tournament_entry.picks.still_alive?(champ) ? 'Y' : 'N'), entry.tie_breaker || '-', round_scores.map {|s| "%3d" % s}.join(" ")] << "\n"
        current_rank += 1
        entry
      end
      out << sep << "\n"
    end
  end

  # Shows detailed scores per entry.  For each pick in each game, shows
  # either a positive amount if the pick was correct, 0 if the pick was
  # incorrect, or a '?' if the game has not yet been played.
  def score_report(out = $stdout)
    # Compute scores
    out << "Total games played: #{tournament_entry.picks.games_played}" << "\n"
    out << "Number of entries: #{@entries.size}" << "\n"
    sep = "-----+---------------+----------------------------------------------------------------------------------"
    if @entries.size > 0
      out << "Total|      Name     | Round Scores" << "\n"
      out << sep << "\n"
      fmt1 = "%5d|%15s|%d: %3d %s" 
      fmt2 = "     |               |%d: %3d %s" 
      fmt3 = "     |               |       %s" 
      @entries.sort_by {|e| -e.picks.score_against(tournament_entry.picks, self.scoring_strategy)}.each do |entry|
        total = entry.picks.score_against(tournament_entry.picks, self.scoring_strategy)
        1.upto(tournament_entry.picks.rounds) do |round|
          scores = entry.picks.scores_for_round(round, tournament_entry.picks, self.scoring_strategy)
          round_total = scores.inject(0) {|sum, arr| sum += (arr[0] ? arr[0] : 0)}
          scores_str = scores.map{|arr| "#{arr[1].short_name}=#{arr[0] ? arr[0] : '?'}"}.join(" ")
          if [1,2].include?(round)
            scores_str_arr = Tournament::Pool.split_line(scores_str, 70)
            if round == 1
              out << fmt1 % [total, entry.name, round, round_total, scores_str_arr[0]] << "\n"
            else
              out << fmt2 % [round, round_total, scores_str_arr[0]] << "\n"
            end
            scores_str_arr[1..-1].each do |ss2|
              out << fmt3 % ss2 << "\n"
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

      output.call('Tournament', tournament_entry.picks, tournament_entry.tie_breaker || '-')

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
      next unless region
      (region[:teams] || []).each do |team|
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
    if self.tournament_entry.picks.teams_left > 4
      out << "The final four report should only be run when there" << "\n"
      out << "are four or fewer teams left in the tournament." << "\n"
      return
    end
    total_payout = @entries.size * @entry_fee.to_i
    # Subtract out constant payments
    total_payout = @payouts.values.inject(total_payout) {|t, amount| t += amount if amount < 0; t}

    use_payouts = @payouts.inject({}) {|h,arr| k = arr[0] != :last ? arr[0].to_i : arr[0]; h[k] = arr[1]; h}
    payout_keys = use_payouts.keys.sort do |a,b|
      if Symbol === a
        1
      elsif Symbol === b
        -1
      else
        a <=> b
      end
    end

    out << "Final Four: #{self.tournament_entry.picks.winners[4][0,2].map{|t| "(#{t.seed}) #{t.name}"}.join(" vs. ")}"
    out << "    #{self.tournament_entry.picks.winners[4][2,2].map{|t| "(#{t.seed}) #{t.name}"}.join(" vs. ")}" << "\n"
    if self.tournament_entry.picks.teams_left <= 2
      out << "Championship: #{self.tournament_entry.picks.winners[5][0,2].map{|t| "(#{t.seed}) #{t.name}"}.join(" vs. ")}" << "\n"
    end
    out << "Payouts" << "\n"
    payout_keys.each do |key|
      amount = if use_payouts[key] > 0
        use_payouts[key].to_f / 100.0 * total_payout
      else
        -use_payouts[key]
      end
      out << "%4s: $%5.2f" % [key, amount] << "\n"
    end
    sep= "--------------+----------------+-----------------------------------------"
    out << "              |                | Winners      Tie    " << "\n"
    out << " Championship |    Champion    | Rank Score Break Name" << "\n"
    out << sep << "\n"
    self.tournament_entry.picks.each_possible_bracket do |poss|
      rankings = @entries.map{|p| [p, p.picks.score_against(poss, self.scoring_strategy)] }.sort do |a1, a2|
         if a1[1] == a2[1]
           # Use tiebreak
           if self.tournament_entry.tie_breaker
             tb1 = (a1[0].tie_breaker - self.tournament_entry.tie_breaker).abs
             tb2 = (a2[0].tie_breaker - self.tournament_entry.tie_breaker).abs
             tb1 <=> tb2
           else
             0
           end 
         else
           a2[1] <=> a1[1]
         end
      end
      finishers = {}
      use_payouts.each do |rank, payout|
        finishers[rank] = {}
        finishers[rank][:payout] = payout
        finishers[rank][:entries] = []
        finishers[rank][:score] = 0
      end
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

  # Runs through every possible outcome of the tournament and
  # calculates each entry's chance to win as a percentage of the
  # possible outcomes the entry would win if the tournment came
  # out that way.  Returns an array of Tournament::Possibility objects for
  # each entry in the pool. These objects respond to :times_champ, :max_score,
  # :min_rank, :entry and :champs methods.  The :entry method returns the
  # Tournament::Entry object and the :champs method returns a hash
  # keyed on team name and whose values are the number of times that
  # team could win that would make the entry come in on top.
  # Options avaliable:
  #   :processes => Number of Threads (default: 1) - Set this to the
  #       number of CPU's on your computer to really peg CPU usage ;)
  # This method spins up N processes to perform the work and will periodically
  # report progress if passed a block responding to three parameters:
  # 1) percentage of possibilities checked, 2) estimated time remaining in seconds
  # and 3) total possibilities checked so far.
  def possibility_stats(options = {})
    options = options || {}
    global_stats = @entries.map do |e|
      Tournament::Possibility.new(e)
    end

    # Create a collector to hold the results
    collector = StatsCollector.new

    # How many workers?
    num_threads = options[:threads] || 1

    threads = if num_threads == 1
      # With just one worker, do it in-process
      [possibility_stats_thread(collector, 0, 1)]
    else
      # With more than one worker, create a drb
      # server and multiple clients
      possibility_stats_cluster(collector, num_threads)
    end

    puts "CREATED WORKERS: #{threads}"

    # Wait for them to finish
    count = 0
    start = Time.now.to_f
    old_remaining = 1_000_000_000_000_000
    old_percentage = 0
    last_thousand = 1000
    total_outcomes = self.tournament_entry.picks.number_of_outcomes
    while count < total_outcomes
      sleep 1
      count = collector.total_count
      next if count == 0
      percentage = (count * 100.0 / total_outcomes)
      elapsed = Time.now.to_f - start
      spp = elapsed / count
      remaining = ((self.tournament_entry.picks.number_of_outcomes - count) * spp).to_i
      if (percentage.to_i != old_percentage) || (remaining < old_remaining) || count > last_thousand
        old_remaining = remaining
        old_percentage = percentage.to_i
        if block_given?
          yield(percentage.to_i, remaining, count)
        end
      end
      if count > last_thousand
        last_thousand = (count / 1000 + 1) * 1000
      end
    end

    # join
    puts
    puts "Waiting for threads to finish"
    threads.each {|t| t.join}
    
    if @drb_server
      puts "Waiting for drb services to stop"
      DRb.stop_service
      if DRb.thread
        DRb.thread.stop
        DRb.thread.join
      end
    end
   
    # Collect all the stats 
    num_threads.times do |n|
      global_stats.each_with_index do |stats, idx|
        stats.merge!(collector.stats_of(n)[idx])
      end
    end
    global_stats.sort!
    return global_stats
  end

  # Runs through every possible outcome of the tournament and calculates
  # each entry's chance to win as a percentage of the possible outcomes
  # the entry would win if the tournament came out that way.  Generates
  # an ASCII report of the results.
  def possibility_report(out = $stdout)
    $stdout.sync = true
    if @entries.size == 0
      out << "There are no entries in the pool." << "\n"
      return
    end
    out << "Checking #{self.tournament_entry.picks.number_of_outcomes} possible outcomes" << "\n"
    stats = possibility_stats(:threads => 2) do |percentage, remaining, num_processed|
      hashes = '#' * (percentage.to_i/5) + '>'
      out << "\rCalculating: %3d%% +#{hashes.ljust(20, '-')}+ %5d seconds remaining, %d" % [percentage.to_i, remaining, num_processed]
    end
    out << "\n"
    #puts "SORT: #{stats.inspect}"
    out << "    Entry           | Win Chance | Highest Place | Curr Score | Max Score | Tie Break  " << "\n"
    out << "--------------------+------------+---------------+------------+-----------+------------" << "\n"
    stats.each do |stat|
      chance = stat.times_champ.to_f * 100.0 / self.tournament_entry.picks.number_of_outcomes
      out << "%19s | %10.2f | %13d | %10d | %9d | %7d " %
        [stat.entry.name, chance, stat.min_rank, stat.entry.picks.score_against(self.tournament_entry.picks, self.scoring_strategy), stat.max_score, stat.entry.tie_breaker] << "\n"
    end
    out << "Possible Champions For Win" << "\n"
    out << "    Entry           |    Champion     |  Ocurrences   |  Chance " << "\n"
    out << "--------------------+-----------------+---------------+---------" << "\n"
    stats.each do |stat|
      next if stat.champs.size == 0
      stat.champs.sort_by{|k,v| -v}.each_with_index do |harr, idx| 
        team = harr[0]
        occurences = harr[1]
        if idx == 0
          out << "%19s | %15s | %13d | %8.2f " % [stat.entry.name, team, occurences, occurences.to_f * 100.0 / stat.times_champ] << "\n"
        else
          out << "%19s | %15s | %13d | %8.2f " % ['', team, occurences, occurences.to_f * 100.0 / stat.times_champ] << "\n"
        end
      end
      out << "--------------------+-----------------+---------------+---------" << "\n"
    end
    nil
  end

  require 'drb/drb'
  URI = "druby://localhost:38787"
  class StatsCollector
    include DRb::DRbUndumped
    def initialize
      @counts = {}
      @stats = {}
    end
    def count(child, count)
      @counts[child] = count
    end
    def stats(child, stat)
      @stats[child] = stat
    end
    def stats_of(child)
      @stats[child]
    end
    def count_of(child)
      @count[child]
    end
    def total_count
      @counts.values.inject(0) {|sum, count| sum += count}
    end
  end

  # Make a subprocess look like a thread
  class StatsProcess
    def initialize(pid)
      @pid = pid
    end
    def join
      Process.waitpid @pid
    end
  end

  protected

  # Starts a drb server that spins off #total_threads child processes
  # that each do a chunk of the calculation.  Returns array
  # of StatsProcess objects that can be joined
  def possibility_stats_cluster(collector, total_threads)
    # Create a drb server
    @drb_server = DRb.start_service(URI, collector)
    threads = []
    total_threads.times do |n|
      pid = fork
      if pid
        # Track the child process
        threads << StatsProcess.new(pid)
      else
        # child
        DRb.start_service
        remote_collector = DRbObject.new_with_uri(URI)
        puts "Child #{n} got remote collector: #{remote_collector.inspect}"
        # Start off collection thread
        t = possibility_stats_thread(remote_collector, n, total_threads)
        # Wait for it to finish 
        t.join
        exit 0
      end
    end
    return threads
  end

  # Compute possibility stats for the given thread num and total threads.
  # Tracks number of possibilities processed in collector and stores 
  # an Array of Tournament::Possibility objects in the collector when
  # finished
  def possibility_stats_thread(collector, thread_num, total_threads)
    puts "Creating stats thread #{thread_num} of #{total_threads}"
    t = Thread.new do
      count = 0
      collector.count(thread_num, count)
      stats = @entries.map do |e|
        Tournament::Possibility.new(e)
      end
      self.tournament_entry.picks.each_possible_bracket(thread_num, total_threads) do |poss|
        poss_scores = @entries.map{|p| p.picks.score_against(poss, self.scoring_strategy)}
        # precalculate ranks
        sorted = poss_scores.sort_by{|s| -s}
        sort_scores = sorted.inject({}) do |h, s|
          h[s] = sorted.index(s) + 1
          h
        end
        @entries.each_with_index do |entry, i|
          score = poss_scores[i]
          stat = stats[i]
          stat.max_score = score if score > stat.max_score
          rank = sort_scores[score]
          stat.min_rank = rank if rank < stat.min_rank
          stat.times_champ += 1 if rank == 1
          if rank == 1
            stat.champs[poss.champion.name] ||= 0
            stat.champs[poss.champion.name] += 1
          end
        end
        count += 1
        if count % 1000 == 0
          collector.count(thread_num, count)
        end
      end
      # Final count and stats
      collector.count(thread_num, count)
      collector.stats(thread_num, stats)
    end
    t.abort_on_exception = true
    t
  end

end
