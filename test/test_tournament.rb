require 'test/unit'
require_relative '../lib/tournament'

class TournamentTest < Test::Unit::TestCase
  def test_random_pool
    Tournament::Pool.test(50)
  end
end
