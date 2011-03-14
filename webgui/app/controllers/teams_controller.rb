class TeamsController < ApplicationController
  before_filter :login_required
  skip_before_filter :verify_authenticity_token, :only => [:auto_complete_for_team_name, :auto_complete_for_short_name]

  def choose
    @pool = Pool.find(params[:id])
  end

  def auto_complete_for_team_name
    region_hash = params[:region0] || params[:region1] || params[:region2] || params[:region3]
    name_like = region_hash[:seedings][0][:name]
    @teams_like = Team.find(:all, :conditions => ['name like ?', "#{name_like}%"], :order => 'name asc')
    logger.debug("auto_complte_for_team_name got teams: #{@teams_like.inspect}")
    render :inline => "<%= content_tag(:ul, @teams_like.map{|t| content_tag(:li, h(t.name), :short => t.short_name)}.join(' ')) %>"
  end

  def auto_complete_for_short_name
    region_hash = params[:region0] || params[:region1] || params[:region2] || params[:region3]
    name_like = region_hash[:seedings][0][:short_name]
    @teams_like = Team.find(:all, :conditions => ['short_name like ?', "#{name_like}%"], :order => 'short_name asc')
    render :inline => "<%= content_tag(:ul, @teams_like.map{|t| content_tag(:li, h(t.short_name), :name => t.name)}.join(' ')) %>"
  end

  def change
    @pool = Pool.find(params[:id])
    Pool.transaction do
    [0,1,2,3].each do |region_idx|
      region_hash = params["region#{region_idx}".to_sym]
      logger.debug("Got region hash: #{region_hash}, index: #{region_idx}")
      next unless region_hash
      region_name = region_hash[:name]
      if region_name.blank? || region_hash[:seedings].blank?
	flash[:error] = "Please specify name of region #{region_idx+1}"
        next
      end
      raise "Illegal input, seedings array contains more than 16 elements" if region_hash[:seedings].length > 16
      region = Region.find_by_pool_id_and_position(@pool.id, region_idx)
      if !region
        region = Region.create(:name => region_name, :pool_id => @pool.id, :position => region_idx)
      else
        if region_name != region.name
          region.name = region_name
          region.save!
        end
      end 
      logger.debug("SAVING SEEDINGS: #{region_hash[:seedings].inspect}")
      region_hash[:seedings].each do |seeding_hash|
        next if seeding_hash[:name].blank? || seeding_hash[:short_name].blank?
        team = Team.find_or_initialize_by_short_name(seeding_hash[:short_name]) {|t| t.name = seeding_hash[:name]}
        if team.new_record?
          logger.debug("SAVING NEW TEAM for region #{region_idx}, seed: #{seeding_hash[:seed]}, name: #{team.name}, short: #{team.short_name}")
          team.save!
        end
        logger.debug "Finding Seeding for region #{region.name}, seed #{seeding_hash[:seed]}"
        existing_seeding = @pool.seedings.find_by_region_and_seed(region.name, seeding_hash[:seed])
        unless existing_seeding
           existing_seeding = @pool.seedings.create(:region => region.name, :seed => seeding_hash[:seed], :team_id => team.id)
        end
        if existing_seeding.team_id != team.id
          logger.debug "  ==> TEAMS ARE DIFF, CHANGING SEEDING: #{existing_seeding.inspect}"
          existing_seeding.team_id = team.id
          existing_seeding.save!
        end
      end
      @pool.save!
      end
      if @pool.teams_set?
        @pool.initialize_tournament_pool
        @pool.save
      end
    end
    redirect_to :action => 'choose', :id => @pool.id
  end

  def authorized?(action = action_name, resource = nil)
    return super && admin_authorized?(action_name, resource)
  end

end
