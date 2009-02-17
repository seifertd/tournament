class EntryController < ApplicationController
  layout 'bracket'
  before_filter :login_required
  before_filter :check_access, :only => [:show, :edit]

  def check_access
    @entry = Entry.find(params[:id])
    if current_user != @entry.user
      flash[:info] = "You don't have access to that entry."
      redirect_to '/'
      return false
    end
    return true
  end

  def new
    @entry = Entry.new
  end

  def index
    @entries = Entry.find_all_by_user_id(current_user.id)
    render :action => 'index', :layout => 'default'
  end

  def show
    @entry.bracket.set_winner(1,1,@entry.bracket.teams[0])
  end

  def edit
    bracket = @entry.bracket
    picks = params[:picks]
    logger.debug("PICKS: #{picks}")
    picks.split(//).each_with_index do |pick, idx|
      round, game = bracket.round_and_game(idx+1)
      logger.debug("Round #{round} game #{game} pick #{pick} idx #{idx}")
      if pick != '0'
        pick = pick.to_i - 1
        team = bracket.matchup(round, game)[pick]
        logger.debug("      --> Team = #{team.name}")
        bracket.set_winner(round, game, team)
      end
    end
    @entry.update_attributes(params[:entry])
    if @entry.save
      flash[:info] = "Changes were saved."
    else
      flash[:error] = "Could not save entry: #{@entry.errors.full_messages.join("<br/>")}."
    end
    redirect_to :action => 'show', :id => params[:id]
  end
end
