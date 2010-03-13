require 'test_helper'

class PoolTest < ActiveSupport::TestCase
  test "new pool is not completed" do
    p = Pool.new
    assert !p.completed?, "new pool should not be completed"
  end
  test "new pool does not have teams set" do
    p = Pool.new
    assert !p.teams_set?, "new pool should not have teams set"
  end
  test "pool that has not started is accepting entries" do
    p = Pool.new
    p.teams = [Team.new] * 64
    p.starts_at = Time.now + 2.days
    assert p.accepting_entries?, "Pool with all teams that starts in future should except entries"
  end
  test "pool that has started is not accepting entries" do
    p = Pool.new
    p.teams = [Team.new] * 64
    p.starts_at = Time.now - 2.days
    assert !p.accepting_entries?, "Pool with all teams that starts in past should not except entries"
  end
end
