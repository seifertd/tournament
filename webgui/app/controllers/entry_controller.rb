class EntryController < ApplicationController
  layout 'bracket'
  before_filter :login_required
  before_filter :check_access, :only => [:show, :edit]
  include SavesPicks

  def check_access
    # Admin user
    return true if current_user.roles.include?(Role[:admin])

    # Check if entry being viewed belongs to current user
    @entry = params[:id] ? Entry.find(params[:id]) : Entry.new({:user_id => current_user.id})
    if current_user != @entry.user
      flash[:info] = "You don't have access to that entry."
      redirect_to '/'
      return false
    end
    return true
  end

  def new
    @entry = Entry.new
    render :action => 'show'
  end

  def index
    @entries = Entry.find_all_by_user_id(current_user.id)
    render :action => 'index', :layout => 'default'
  end

  def show
    #@entry.bracket.set_winner(1,1,@entry.bracket.teams[0])
  end

  def edit
    save_picks(@entry)
    if @entry.save
      flash[:info] = "Changes were saved."
      redirect_to :action => 'show', :id => @entry.id
    else
      flash[:error] = "Could not save entry."
      render :action => 'show', :id => @entry.id
    end
  end
end
