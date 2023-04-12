require 'benchmark'
require 'tournament'

pool = Tournament::Pool.ncaa_2008
    pool.entry_fee = 10
    pool.set_payout(1, 70)
    pool.set_payout(2, 20)
    pool.set_payout(3, 10)
    pool.set_payout(:last, -10)
    pool.scoring_strategy = Tournament::ScoringStrategy::Basic.new
    b = pool.tournament_entry.picks
    # Play out the bracket
    32.times { |n| b.set_winner(1,n+1, b.matchup(1, n+1)[rand(2)])}
    16.times { |n| b.set_winner(2,n+1, b.matchup(2, n+1)[rand(2)])}
    8.times { |n| b.set_winner(3,n+1, b.matchup(3, n+1)[rand(2)])}
    4.times { |n| b.set_winner(4,n+1, b.matchup(4, n+1)[rand(2)])}
    2.times { |n| b.set_winner(5,n+1, b.matchup(5, n+1)[rand(2)])}
    1.times { |n| b.set_winner(6,n+1, b.matchup(6, n+1)[rand(2)])}
    puts "BRACKET: #{b.inspect}"

entries = (1..10).to_a.map{|n| Tournament::Bracket.random_bracket(b.teams)}
puts "ENTRIES: #{entries.length} entries"

n = 10_000
puts "#{n} scores of perfect bracket"
Benchmark.bm(10) do |x|
  x.report(:basic) do
    n.times { entries.each {|p| p.score_against(b, pool.scoring_strategy)}  }
  end
end
