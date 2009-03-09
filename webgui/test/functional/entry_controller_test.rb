require 'test_helper'

class EntryControllerTest < ActionController::TestCase
  include AuthenticatedTestHelper
  # Replace this with your real tests.
  test "pool stops taking edits after it starts" do
    login_as :quentin
    pool = Pool.find(2)
    assert pool.accepting_entries?, "Pool with id = 4 should be taking entries."
    post(:edit, {:picks => "111000000000000000000000000000000000000000000000000000000000000",
      :id => 1, :entry => {:name => 'Test', :tie_break => 42}, :pool_id => 2})
    assert_redirected_to :action => 'show'
    assert_nil flash[:error]
    assert_equal "Changes were saved.", flash[:info]
    assert_equal "You still have remaining games in this entry to pick.", flash[:notice]

    # Now change the started date
    p = Pool.find(2)
    p.starts_at = Time.now - 5.days
    p.save!

    post(:edit, {:picks => "111000000000000000000000000000000000000000000000000000000000000",
      :id => 1, :entry => {:name => 'Test', :tie_break => 42}, :pool_id => 2})
    assert_redirected_to :action => 'show'
    assert_equal "You can't make changes to your entry, the pool has already started.", flash[:error]
  end
end
