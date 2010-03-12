class UserMailer < ActionMailer::Base
  def signup_notification(user, activation_url)
    setup_email(user)
    @body[:user] = user
    @subject    += 'Please activate your new account'
    @body[:url]  = activation_url
  end
  
  def activation(user, home_url)
    setup_email(user)
    @body[:user] = user
    @subject    += 'Your account has been activated!'
    @body[:url]  = home_url
  end

  def recap(users, subject, content, home_url)
    setup_email(users[0])
    @recipients = ADMIN_EMAIL
    @bcc = users.map{|u| u.email}
    @subject << subject
    @body[:content] = content
    @body[:url] = home_url
  end

  def password_reset_notification(user, reset_url)
    setup_email(user)
    @subject    = 'Link to reset your password'
    @body[:url]  = reset_url
   end
  
  protected
    def setup_email(user)
      @user = user
      @recipients  = user.email
      @from        = ADMIN_EMAIL
      @subject     = "[#{TOURNAMENT_TITLE}] "
      @sent_on     = Time.now
    end
end
