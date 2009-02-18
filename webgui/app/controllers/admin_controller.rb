class AdminController < ApplicationController
  before_filter :login_required
  include SavesPicks

  def edit
    @entry = Entry.find_by_user_id(current_user.id)
    if @entry
      save_picks(@entry)
      if @entry.save
        $pool.bracket = @entry.bracket
        Tournament.save_pool
        flash[:info] = "Tournament bracket updated."
        redirect_to :action => 'bracket'
      else
        flash[:error] = "Could not save entry."
        render :action => 'bracket', :layout => 'bracket'
      end
    else
      flash[:error] = "Tournament bracket has not yet been initialized."
    end
  end

  def entries
  end

  def reports
  end

  def pool
  end

  def bracket
    @entry = Entry.find_or_initialize_by_user_id(:user_id => current_user.id, :tie_break => 0, :name => 'Tournament Bracket')
    @entry.bracket
    @entry.save!
      
    render :layout => 'bracket'
  end

  def authorized?(action = action_name, resource = nil)
    super && current_user.roles.include?(Role[:admin])    
  end

end
