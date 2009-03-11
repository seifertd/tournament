# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  layout 'default'
  include AuthenticatedSystem
  #helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '24a18931c02e0d07b788d1298b19f7b7'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  def admin_authorized?(action = action_name, resource = nil)
    unless current_user.roles.include?(Role[:admin])
      flash[:info] = "You are not authorized to perform that action."
      return false
    end
    return true
  end
end
