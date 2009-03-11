class EntryController < ApplicationController
  layout 'bracket'
  before_filter :login_required
  before_filter :check_access, :only => [:show, :edit, :print, :pdf]
  before_filter :pool_taking_edits, :only => [:edit]
  include SavesPicks
  include PdfHelper

  def check_access
    # Resolve the entry
    @entry = params[:id] ? Entry.find(params[:id]) : Entry.new({:user_id => current_user.id, :pool_id => params[:pool_id]})

    # Admin user
    return true if current_user.has_role?(:admin)

    # Check if entry being viewed belongs to current user
    if current_user != @entry.user
      flash[:info] = "You don't have access to that entry."
      redirect_to root_path
      return false
    end
    return true
  end

  def pool_taking_edits
    # Admin user can do anything
    return true if current_user.has_role?(:admin)
    
    if Time.now > @entry.pool.starts_at
      flash[:error] = "You can't make changes to your entry, the pool has already started."
      redirect_to :action => 'show'
      return false
    end

    return true
  end

  def new
    @entry = Entry.new(:pool_id => params[:id])
    @pool = @entry.pool.pool
    render :action => 'show'
  end

  def index
    @pool = Pool.find(params[:id])
    @entries = Entry.find_all_by_user_id_and_pool_id(current_user.id, @pool.id)
    render :action => 'index', :layout => 'default'
  end

  def show
    @pool = @entry.pool.pool
  end

  def print
    @pool = @entry.pool.pool
    render :layout => 'print'
  end

  def pdf
    @pool = @entry.pool.pool
    make_and_send_pdf("/entry/print", 'entry.pdf', true)
  end

  def edit
    if params[:reset] == 'Reset Picks'
      @entry.reset
      if @entry.new_record?
        redirect_to :action => 'new', :id => params[:pool_id]
        return
      end
    elsif params[:cancel] == 'Cancel Changes'
      flash[:info] = "Changes were <b>canceled</b>."
      if @entry.new_record?
        redirect_to :action => 'index', :id => params[:pool_id]
      else
        redirect_to :action => 'show', :id => @entry.id
      end
      return
    else
      save_picks(@entry)
    end
    logger.debug("SAVING ENTRY")
    if @entry.save
      logger.debug("DONE SAVING ENTRY")
      flash[:info] = "Changes were saved."
      if !@entry.completed
        flash[:notice] = "You still have remaining games in this entry to pick."
      else
        flash[:notice] = "You have made all picks in this entry."
      end
      redirect_to :action => 'show', :id => @entry.id
    else
      flash[:error] = "Could not save entry."
      render :action => 'show', :id => @entry.id
    end
  end
end
