class AdminController < ApplicationController
  before_filter :login_required
  include SavesPicks

  def edit
    @entry = Entry.find_by_user_id(current_user.id)
    if @entry
      @pool = @entry.pool
      save_picks(@entry)
      if @entry.save
        @pool.pool.bracket = @entry.bracket
        @pool.save
        flash[:info] = "Tournament bracket updated."
        redirect_to :action => 'bracket', :id => @pool.id
      else
        flash[:error] = "Could not save entry."
        render :action => 'bracket', :layout => 'bracket'
      end
    else
      flash[:error] = "Tournament bracket has not yet been initialized."
    end
  end

  def entries
    @pool = Pool.find(params[:id])
  end

  def index
    @pools = Pool.find(:all)
  end

  def pool
    @available_scoring_strategies = Tournament::ScoringStrategy.available_strategies.map{|n| Tournament::ScoringStrategy.strategy_for_name(n)}
    @pool = params[:id] ? Pool.find(params[:id]) : Pool.new
    if request.post?
      @pool.attributes = params[:pool]
      @pool.user_id ||= current_user.id
      if @pool.valid?
        @pool.save!
        # reload it
        @pool = Pool.find(@pool.id)
      end
    end
  end

  def bracket
    pool = Pool.find(params[:id])
    # This is confusing ...
    @pool = pool.pool
    @entry = Entry.find_or_initialize_by_user_id(:user_id => current_user.id, :pool_id => pool.id, :tie_break => 0, :name => 'Tournament Bracket')
    @entry.bracket
    @entry.save!
      
    render :layout => 'bracket'
  end

  def authorized?(action = action_name, resource = nil)
    return super && admin_authorized?(action_name, resource)
  end

end
