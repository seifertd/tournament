require 'test/unit'
require 'tournament'

class TournamentTest < Test::Unit::TestCase
  def test_random_pool
    Tournament::Pool.test(50)
  end
end
