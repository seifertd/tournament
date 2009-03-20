require 'test_helper'

class AdminControllerTest < ActionController::TestCase
  include AuthenticatedTestHelper
  fixtures :users, :roles, :roles_users
  # Replace this with your real tests.
  test "send recap" do
    login_as :admin
    post(:recap, {:subject => 'subject', :content => 'content'})
    assert_response :success
    assert_equal 1, ActionMailer::Base.deliveries.size, "There should have been an email sent."
    mail = ActionMailer::Base.deliveries.first
    assert_equal [ADMIN_EMAIL], mail.to
    recips = User.find(:all).delete_if{|u| u.has_role?(:admin)}.map{|u| u.email}
    assert_equal recips, mail.bcc
    assert_equal "[#{TOURNAMENT_TITLE}] subject", mail.subject
    assert_match /content/, mail.body
  end
end
