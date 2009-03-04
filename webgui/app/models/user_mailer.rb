class UserMailer < ActionMailer::Base
  def signup_notification(user, activation_url)
    setup_email(user)
    @subject    += 'Please activate your new account'
  
    #@body[:url]  = "#{TOURNAMENT_FQ_WEBROOT}/activate/#{user.activation_code}"
    @body[:url]  = activation_url
  
  end
  
  def activation(user, home_url)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = home_url
  end
  
  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = ADMIN_EMAIL
      @subject     = "[#{TOURNAMENT_TITLE}] "
      @sent_on     = Time.now
      @body[:user] = user
    end
end
