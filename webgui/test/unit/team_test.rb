require 'test_helper'

class TeamTest < ActiveSupport::TestCase
  fixtures :teams

  test "michigan exists" do
    t = Team.find_by_short_name('UM')
    assert_not_nil t
  end
end
