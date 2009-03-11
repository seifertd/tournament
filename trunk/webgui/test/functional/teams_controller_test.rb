require 'test_helper'

class TeamsControllerTest < ActionController::TestCase
  include AuthenticatedTestHelper
  fixtures :pools, :teams, :seedings, :users, :roles, :roles_users
  test "set 1 team" do
    initial_seedings = Seeding.count
    login_as :admin
    post :change, {:id => 1, :region0 => {:name => 'Midwest',
      :seedings => [{:name => 'Michigan', :short_name => 'UM', :seed => 1}]}}
    after_seedings = Seeding.count

    assert_equal 1, after_seedings - initial_seedings, "There should be one additional seeding."

    pool_regions = Pool.find(1).region_seedings
    assert_equal 1, pool_regions.find_all{|name, seedings| !name.blank?}.size, "There should be one region with a name."

    midwest, midwest_seedings = pool_regions.find{|name,seedings| name == 'Midwest'}

    assert_not_nil midwest
    assert_not_nil midwest_seedings
    t = Team.find_by_short_name("UM")
    assert_equal t, midwest_seedings[0]
  end

  test "set 2 teams same region" do
    initial_seedings = Seeding.count
    login_as :admin
    post :change, {:id => 1, :region0 => {:name => 'Midwest',
      :seedings => [{:name => 'Michigan', :short_name => 'UM', :seed => 1},
      {:name => 'Michigan State', :short_name => 'MSU', :seed => 16}]}}
    after_seedings = Seeding.count

    assert_equal 2, after_seedings - initial_seedings, "There should be two additional seedings."

    pool_regions = Pool.find(1).region_seedings
    assert_equal 1, pool_regions.find_all{|name, seedings| !name.blank?}.size, "There should be one region with a name."

    midwest, midwest_seedings = pool_regions.find{|name,seedings| name == 'Midwest'}

    assert_not_nil midwest
    assert_not_nil midwest_seedings
    t = Team.find_by_short_name("UM")
    assert_equal t, midwest_seedings[0]
    t = Team.find_by_short_name("MSU")
    assert_equal t, midwest_seedings[15]
  end

  test "set 2 teams different regions" do
    initial_seedings = Seeding.count
    login_as :admin
    post :change, {:id => 1, :region0 => {:name => 'Midwest',
      :seedings => [{:name => 'Michigan', :short_name => 'UM', :seed => 1}]},
      :region3 => {:name => 'South', :seedings => [{:name => "Michigan State", :short_name => 'MSU', :seed => 1}]}}
    after_seedings = Seeding.count

    assert_equal 2, after_seedings - initial_seedings, "There should be two additional seedings."

    p = Pool.find(1)
    #puts "REGIONS: #{p.regions.inspect}"
    #puts "REGION_SEEDINGS: #{p.region_seedings.inspect}"

    pool_regions = Pool.find(1).region_seedings
    assert_equal 2, pool_regions.find_all{|name, seedings| !name.blank?}.size, "There should be two regions with a name."

    midwest, midwest_seedings = pool_regions.find{|name,seedings| name == 'Midwest'}
    south, south_seedings = pool_regions.find{|name,seedings| name == 'South'}

    assert_not_nil midwest
    assert_not_nil midwest_seedings
    t = Team.find_by_short_name("UM")
    assert_equal t, midwest_seedings[0]

    assert_not_nil south
    assert_not_nil south_seedings
    t = Team.find_by_short_name("MSU")
    assert_equal t, south_seedings[0]

    midwest = Pool.find(1).regions.find_by_name('Midwest')
    assert_equal 0, midwest.position
    south = Pool.find(1).regions.find_by_name('South')
    assert_equal 3, south.position
  end

  test "set 1 team with blanks" do
    initial_seedings = Seeding.count
    login_as :admin
    post :change, {:id => 1, :region0 => {:name => 'Midwest',
      :seedings => [{:name => 'Michigan', :short_name => 'UM', :seed => 1},
      {:name => '', :short_name => '', :seed => 2}]},
      :region1 => {:name => '', :seedings => [{:name => '', :short_name => '', :seed => 1}]}}
    after_seedings = Seeding.count

    assert_equal 1, after_seedings - initial_seedings, "There should be one additional seeding."

    pool_regions = Pool.find(1).region_seedings
    assert_equal 1, pool_regions.find_all{|name, seedings| !name.blank?}.size, "There should be one region with a name."

    midwest, midwest_seedings = pool_regions.find{|name,seedings| name == 'Midwest'}

    assert_not_nil midwest
    assert_not_nil midwest_seedings
    t = Team.find_by_short_name("UM")
    assert_equal t, midwest_seedings[0]
  end

  test "set the entire tournament" do
    input = {"id" => 1, "region3"=>{"name"=>"West",
     "seedings"=>[{"name"=>"UCLA", "seed"=>"1", "short_name"=>"ULA"},
     {"name"=>"Duke", "seed"=>"2", "short_name"=>"Duk"},
     {"name"=>"Xavier", "seed"=>"3", "short_name"=>"Xav"},
     {"name"=>"Connecticut", "seed"=>"4", "short_name"=>"Con"},
     {"name"=>"Drake", "seed"=>"5", "short_name"=>"Dra"},
     {"name"=>"Purdue", "seed"=>"6", "short_name"=>"Pur"},
     {"name"=>"West Virginia", "seed"=>"7", "short_name"=>"WVa"},
     {"name"=>"BYU", "seed"=>"8", "short_name"=>"BYU"},
     {"name"=>"Texas A&M", "seed"=>"9", "short_name"=>"A&M"},
     {"name"=>"Arizona", "seed"=>"10", "short_name"=>"UA"},
     {"name"=>"Baylor", "seed"=>"11", "short_name"=>"Bay"},
     {"name"=>"W. Kentucky", "seed"=>"12", "short_name"=>"WKy"},
     {"name"=>"San Diego", "seed"=>"13", "short_name"=>"SD"},
     {"name"=>"Georgia", "seed"=>"14", "short_name"=>"UG"},
     {"name"=>"Belmont", "seed"=>"15", "short_name"=>"Bel"},
     {"name"=>"Mis. Valley St", "seed"=>"16", "short_name"=>"MVS"}]},
     "region0"=>{"name"=>"East",
     "seedings"=>[{"name"=>"North Carolina", "seed"=>"1", "short_name"=>"UNC"},
     {"name"=>"Tennessee", "seed"=>"2", "short_name"=>"Ten"},
     {"name"=>"Louisville", "seed"=>"3", "short_name"=>"Lou"},
     {"name"=>"Washington St.", "seed"=>"4", "short_name"=>"WSt"},
     {"name"=>"Notre Dame", "seed"=>"5", "short_name"=>"ND"},
     {"name"=>"Oklahoma", "seed"=>"6", "short_name"=>"Okl"},
     {"name"=>"Butler", "seed"=>"7", "short_name"=>"But"},
     {"name"=>"Indiana", "seed"=>"8", "short_name"=>"Ind"},
     {"name"=>"Arkansas", "seed"=>"9", "short_name"=>"Ark"},
     {"name"=>"South Alabama", "seed"=>"10", "short_name"=>"SAl"},
     {"name"=>"St. Joseph's", "seed"=>"11", "short_name"=>"StJ"},
     {"name"=>"George Mason", "seed"=>"12", "short_name"=>"GM"},
     {"name"=>"Winthrop", "seed"=>"13", "short_name"=>"Win"},
     {"name"=>"Boise St.", "seed"=>"14", "short_name"=>"BSt"},
     {"name"=>"American", "seed"=>"15", "short_name"=>"Am"},
     {"name"=>"Mt. St. Mary's", "seed"=>"16", "short_name"=>"MSM"}]},
     "region1"=>{"name"=>"Midwest",
     "seedings"=>[{"name"=>"Kansas", "seed"=>"1", "short_name"=>"Kan"},
     {"name"=>"Georgetown", "seed"=>"2", "short_name"=>"GT"},
     {"name"=>"Wisconsin", "seed"=>"3", "short_name"=>"Wis"},
     {"name"=>"Vanderbilt", "seed"=>"4", "short_name"=>"Van"},
     {"name"=>"Clemson", "seed"=>"5", "short_name"=>"Clm"},
     {"name"=>"USC", "seed"=>"6", "short_name"=>"USC"},
     {"name"=>"Gonzaga", "seed"=>"7", "short_name"=>"Gon"},
     {"name"=>"UNLV", "seed"=>"8", "short_name"=>"ULV"},
     {"name"=>"Kent St.", "seed"=>"9", "short_name"=>"KSt"},
     {"name"=>"Davidson", "seed"=>"10", "short_name"=>"Dav"},
     {"name"=>"Kansas St.", "seed"=>"11", "short_name"=>"KSU"},
     {"name"=>"Villanova", "seed"=>"12", "short_name"=>"Vil"},
     {"name"=>"Siena", "seed"=>"13", "short_name"=>"Sie"},
     {"name"=>"CSU Fullerton", "seed"=>"14", "short_name"=>"CSF"},
     {"name"=>"UMBC", "seed"=>"15", "short_name"=>"UBC"},
     {"name"=>"Portland St.", "seed"=>"16", "short_name"=>"PSt"}]},
     "region2"=>{"name"=>"South",
     "seedings"=>[{"name"=>"Memphis", "seed"=>"1", "short_name"=>"Mem"},
     {"name"=>"Texas", "seed"=>"2", "short_name"=>"Tex"},
     {"name"=>"Stanford", "seed"=>"3", "short_name"=>"Sta"},
     {"name"=>"Pittsburgh", "seed"=>"4", "short_name"=>"Pit"},
     {"name"=>"Michigan St.", "seed"=>"5", "short_name"=>"MSU"},
     {"name"=>"Marquette", "seed"=>"6", "short_name"=>"Mar"},
     {"name"=>"Miami (FL)", "seed"=>"7", "short_name"=>"Mia"},
     {"name"=>"Mississippi St.", "seed"=>"8", "short_name"=>"MiS"},
     {"name"=>"Oregon", "seed"=>"9", "short_name"=>"Ore"},
     {"name"=>"St. Mary's", "seed"=>"10", "short_name"=>"StM"},
     {"name"=>"Kentucky", "seed"=>"11", "short_name"=>"Ken"},
     {"name"=>"Temple", "seed"=>"12", "short_name"=>"Tem"},
     {"name"=>"Oral Roberts", "seed"=>"13", "short_name"=>"ORo"},
     {"name"=>"Cornell", "seed"=>"14", "short_name"=>"Cor"},
     {"name"=>"Austin Peay", "seed"=>"15", "short_name"=>"APe"},
     {"name"=>"TX Arlington", "seed"=>"16", "short_name"=>"TxA"}]}}
    login_as :admin
    post :change, input
    p = Pool.find(1)
    assert_not_nil p.data, "The Tournament::Pool object should be saved."
    assert Tournament::Pool === p.pool, "The Tournament::Pool object is not the right class."
    assert_equal 4, p.pool.regions.size, "The Tournament::Pool should have 4 regions"
    p.pool.regions.each_with_index do |region, idx|
      assert_equal 16, region[:teams].size
      assert_equal 16, region[:teams].uniq.size, "There were duplicate teams in region #{region}"
    end
    # Spot check some teams
    assert_equal 'North Carolina', p.pool.regions[0][:teams][0].name
  end

  test "save full bracket twice" do
    input = {"id" => 1, "region0"=>{"name"=>"West",
     "seedings"=>[{"name"=>"UCLA", "seed"=>"1", "short_name"=>"ULA"},
     {"name"=>"Duke", "seed"=>"2", "short_name"=>"Duk"},
     {"name"=>"Xavier", "seed"=>"3", "short_name"=>"Xav"},
     {"name"=>"Connecticut", "seed"=>"4", "short_name"=>"Con"},
     {"name"=>"Drake", "seed"=>"5", "short_name"=>"Dra"},
     {"name"=>"Purdue", "seed"=>"6", "short_name"=>"Pur"},
     {"name"=>"West Virginia", "seed"=>"7", "short_name"=>"WVa"},
     {"name"=>"BYU", "seed"=>"8", "short_name"=>"BYU"},
     {"name"=>"Texas A&M", "seed"=>"9", "short_name"=>"A&M"},
     {"name"=>"Arizona", "seed"=>"10", "short_name"=>"UA"},
     {"name"=>"Baylor", "seed"=>"11", "short_name"=>"Bay"},
     {"name"=>"W. Kentucky", "seed"=>"12", "short_name"=>"WKy"},
     {"name"=>"San Diego", "seed"=>"13", "short_name"=>"SD"},
     {"name"=>"Georgia", "seed"=>"14", "short_name"=>"UG"},
     {"name"=>"Belmont", "seed"=>"15", "short_name"=>"Bel"},
     {"name"=>"Mis. Valley St", "seed"=>"16", "short_name"=>"MVS"}]}}
    login_as :admin
    post :change, input
    pool = Pool.find(1)
    post :change, input
    pool = Pool.find(1)
    assert_equal 16, pool.region_seedings[0][1].uniq.size, "OOPS! There are dupe teams in region 0 teams list"
    assert_equal input["region0"]["seedings"].map {|h| h["short_name"]}, pool.region_seedings[0][1].uniq.map{|t| t.short_name}, "Teams are out of order or otherwise not equal"
  end
end
