require 'tournament'
require 'yaml'

TOURNAMENT_TITLE = "2009 NCAA Tournament"
POOL_SAVE_FILE = File.join(RAILS_ROOT, 'db', 'pool.yml')

module Tournament
  def self.save_pool
    File.open(POOL_SAVE_FILE, 'w') do |out|
      YAML::dump($pool, out)
    end
  end
end

if File.exist?(POOL_SAVE_FILE)
  $pool = YAML::load_file(POOL_SAVE_FILE)
else
  $pool = Tournament::Pool.ncaa_2008
  # initialize the bracket
  $pool.bracket
  Tournament.save_pool
end
