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
    assert_redirected_to :controller => 'entry', :action => 'show', :id => 1
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

  test "can edit new entry" do
    login_as :quentin
    pool = Pool.find(2)
    get :new, :id => pool.id
    entry = assigns['entry']
    assert_not_nil entry, "Entry should be set"
    assert entry.new_record?, "Entry should be new, not saved"
    assert_select "span[class~='teamname']" do |elems|
      elems.each do |elem|
        assert elem.attributes["onclick"].length() > 0, "There should be onclick handlers on the teamname spans."
      end
    end
  end

  test "can not edit tournament entry" do
    login_as :quentin
    pool = Pool.find(2)
    get :show, :id => pool.tournament_entry.id
    entry = assigns['entry']
    assert_not_nil entry, "Entry should be set"
    assert !entry.new_record?, "Entry should not be new"
    assert_select "span[class~='teamname']" do |elems|
      elems.each do |elem|
        assert elem.attributes["onclick"].length() == 0, "There should not be onclick handlers on the teamname spans."
      end
    end
  end


  test "entry can change name" do
    login_as :quentin
    pool = Pool.find(2)
    # SHould have 1 pending entry 
    assert_equal 1, pool.pending_entries.size, "Should have 1 pending entry"
    assert_equal 1, pool.user_entries.size, "Should have 1 user entry"
    post(:edit, {:picks => "111222222222222222222222222222222222222222222222222222222222222",
      :id => 1, :entry => {:name => 'Test', :tie_break => 42}, :pool_id => 2})
    # Should have 1 completed entry
    pool = Pool.find(2)
    assert_equal 0, pool.pending_entries.size, "Should have 0 pending entries."
    assert_equal 1, pool.user_entries.size, "Should have 1 user entry."
    assert_equal pool.user_entries.size, pool.pool.entries.size, "AR and backing pool should have same number of entries"
    assert_equal ['Test'], pool.user_entries.map{|e| e.name}
    assert_equal ['Test'], pool.pool.entries.map{|e| e.name}

    # Change entry name
    post(:edit, {:picks => "111222222222222222222222222211111222222222222222222222222222222",
      :id => 1, :entry => {:name => 'New Name', :tie_break => 42}, :pool_id => 2})
    pool = Pool.find(2)
    assert_equal 0, pool.pending_entries.size, "Should have 0 pending entries."
    assert_equal 1, pool.user_entries.size, "AR pool should have 1 user entry."
    assert_equal 1, pool.pool.entries.size, "Backing pool should have 1 user entry."
    assert_equal ['New Name'], pool.user_entries.map{|e| e.name}
    assert_equal ['New Name'], pool.pool.entries.map{|e| e.name}
  end
end
