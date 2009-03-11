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
    render :inline => "<%= content_tag(:ul, @teams_like.map{|t| content_tag(:li, h(t.name), :short => t.short_name)}) %>"
  end

  def auto_complete_for_short_name
    region_hash = params[:region0] || params[:region1] || params[:region2] || params[:region3]
    name_like = region_hash[:seedings][0][:short_name]
    @teams_like = Team.find(:all, :conditions => ['short_name like ?', "#{name_like}%"], :order => 'short_name asc')
    render :inline => "<%= content_tag(:ul, @teams_like.map{|t| content_tag(:li, h(t.short_name), :name => t.name)}) %>"
  end

  def change
    @pool = Pool.find(params[:id])
    [0,1,2,3].each do |region_idx|
      region_hash = params["region#{region_idx}".to_sym]
      next unless region_hash
      region_name = region_hash[:name]
      next if region_name.blank? || region_hash[:seedings].blank?
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
        team = Team.find_or_create_by_short_name(seeding_hash[:short_name], :name => seeding_hash[:name])
        existing_region = @pool.region_seedings.find{|rn, rs| rn == region_name}
        existing_team = nil
        if existing_region
          existing_team = existing_region[1][seeding_hash[:seed].to_i - 1]
        end
        if existing_team
          logger.debug "COMPARING existing team #{existing_team.inspect} with new team #{team.inspect}"
          if existing_team != team
            # Change team ...
            existing_seeding = @pool.seedings.find(:first, :conditions => {:team_id => existing_team.id, :region => region_name})
            logger.debug "  ==> TEAMS ARE DIFF, CHANGING SEEDING: #{existing_seeding.inspect}"
            existing_seeding.team_id = team.id
            existing_seeding.save!
          end
        else
          @pool.seedings.create(:team_id => team.id, :region => region_name, :seed => seeding_hash[:seed])
        end 
      end
      @pool.save
      if @pool.ready?
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
