namespace :report do
  desc 'Run the possibility report.'
  task :possibilities, [:pool_id] => [:environment] do |t, args|
    $stdout.sync = true
    pool_id = args[:pool_id].to_i
    tournament_pool = Pool.find(pool_id).pool
    puts "Calculating stats for pool with #{tournament_pool.tournament_entry.picks.number_of_outcomes} possible outcomes ..."
    stats = tournament_pool.possibility_stats do |percentage, remaining|
      hashes = '#' * (percentage.to_i/5) + '>'
      print "\rCalculating: %3d%% +#{hashes.ljust(20, '-')}+ %5d seconds remaining" % [percentage.to_i, remaining]
    end
    puts
    stats_yaml_file = File.join(RAILS_ROOT, 'db', 'stats.yml')
    bytes = File.open(stats_yaml_file, "w") {|f| f.write YAML.dump(stats)}
    puts "Wrote #{bytes} bytes to #{stats_yaml_file} ..."
  end
end
