class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  # include AuthenticatedSystem
  

  # render new.rhtml
  def new
    @user = User.new
  end
 
  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    success = @user && @user.save
    if success && @user.errors.empty?
      email_error = false
      begin
        UserMailer.deliver_signup_notification(user, activate_path(:activation_code => user.activation_code, :only_path => false))
      rescue Exception => e
        logger.error("ERROR: Could not deliver activation request email, user account will remain unactive: #{e}")
        email_error = true
      end
      redirect_back_or_default(root_path)
      flash[:notice] = "Thanks for signing up! "
      unless email_error
        flash[:notice] << " We're sending you an email with your activation code."
      else
        flash[:error] = "We were unable to send you an activation email, please contact the pool administrator to get your account activated."
      end
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      render :action => 'new'
    end
  end

  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      begin
        UserMailer.deliver_activation(user, root_path(:only_path => false)) if user.recently_activated?
      rescue Exception => e
        logger.error("Could not deliver post-activation email: #{e}")
      end
      flash[:notice] = "Signup complete! Please sign in to continue."
      redirect_to login_path
    when params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_back_or_default(root_path)
    else 
      flash[:error]  = "We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_back_or_default(root_path)
    end
  end
end
