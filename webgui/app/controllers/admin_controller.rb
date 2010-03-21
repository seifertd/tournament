class AdminController < ApplicationController
  before_filter :login_required
  include SavesPicks

  def edit
    @entry = Entry.find(params[:id])
    if @entry
      @pool = @entry.pool
      if params[:reset] == 'Reset Picks'
        @entry.reset
        flash[:info] = "Tournament bracket reset."
      else
        save_picks(@entry)
        flash[:info] = "Tournament bracket updated."
      end
      if @entry.save_with_validation(false)
        @pool.pool.tournament_entry = @entry.tournament_entry
        @pool.save
        redirect_to :action => 'bracket', :id => @pool.id
        return
      else
        @pool = @pool.pool
        flash[:info] = nil
        flash[:error] = "Could not save entry."
        render :action => 'bracket', :layout => 'bracket'
        return
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

  def recap
    @pool = Pool.find(params[:id])
    if request.post?
      begin
        UserMailer.deliver_recap(@pool.entrants, params[:subject], params[:content], root_path(:only_path => false))
        flash[:notice] = "Email was delivered."
      rescue Exception => e
        flash[:error] = "Email could not be delivered: #{e}"
        logger.error "Could not send recap email: #{e}"
        e.backtrace.each{|b| logger.error(b)}
      end
    end
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
    @entry = Entry.find_or_initialize_by_user_id_and_pool_id(current_user.id, pool.id) do |e|
      e.tie_break = 0
      e.name = 'Tournament Bracket'
    end
    @entry.bracket
    @entry.save(false)
      
    render :layout => 'bracket'
  end

  def authorized?(action = action_name, resource = nil)
    return super && admin_authorized?(action_name, resource)
  end

end
