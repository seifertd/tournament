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
        UserMailer.deliver_signup_notification(@user, activate_path(:activation_code => @user.activation_code, :only_path => false))
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
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin."
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

  def lost_password
    case request.method
    when :post
      logout_keeping_session!
      @user = User.new(params[:user])
      @user.confirming_email = true
      @user.updating_email = false
      if valid_for_attributes(@user, ["email","email_confirmation"])
        user = User.find_by_email(params[:user][:email])
        if user
          user.create_password_reset_code
          UserMailer.deliver_password_reset_notification(user, reset_password_path(:reset_code => user.password_reset_code, :only_path => false))
        end
        flash[:notice] = "Reset code sent to #{params[:user][:email]}"
        redirect_back_or_default(root_path)
      else
        flash[:error] = "Please enter a valid email address"
      end
    when :get
      @user = User.new
    end
  end

  def reset_password
    @user = User.find_by_password_reset_code(params[:reset_code]) unless params[:reset_code].nil?
    if !@user
      flash[:error] = "Reset password token invalid, please contact support."
      redirect_to(root_path)
      return
    else
      @user.crypted_password = nil
    end
    if request.post?
      if @user.update_attributes(:password => params[:user][:password], :password_confirmation => params[:user][:password_confirmation])
        #self.current_user = @user
        @user.delete_password_reset_code
        flash[:notice] = "Password updated successfully for #{@user.email} - You may now log in using your new password."
        redirect_back_or_default(root_path)
      else
        render :action => :reset_password
      end
    end
  end
 
  # Might be a good addition to AR::Base
  def valid_for_attributes( model, attributes )
    unless model.valid?
      errors = model.errors
      our_errors = Array.new
      errors.each do |attr,error|
        if attributes.include? attr
          our_errors << [attr,error]
        end
      end
      errors.clear
      our_errors.each { |attr,error| errors.add(attr,error) }
      return false unless errors.empty?
    end
    return true
  end
end
