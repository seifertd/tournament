require 'tournament'
require 'yaml'

# The page title and email subject line:
# <title>#{TOURNAMENT_TITLE}</title>
# or Subject: [#{TOURNAMENT_TITLE}] Your registration was successful!
TOURNAMENT_TITLE = "Tournament"

# The email address emails sent by the site will be fron
ADMIN_EMAIL = 'admin' unless defined?(ADMIN_EMAIL)

# If the application is installed as a relative directory
# in an existing site, use this in conjunction with the
# appropriate web server configuration to have all urls
# in the site done relative to the root url.
RELATIVE_URL_ROOT = nil

if RELATIVE_URL_ROOT
  # Need to do this two ways in Rails 2.3.5?
  config = Rails::Configuration.new
  config.action_controller.relative_url_root = RELATIVE_URL_ROOT
  ActionController::Base.relative_url_root = RELATIVE_URL_ROOT
end

# Provide keys needed by ActionMailer.smtp_settings.  See Rails
# documentation for more help
SMTP_CONFIGURATION = {}

if SMTP_CONFIGURATION.size > 0
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = SMTP_CONFIGURATION
end

# Full path to the prince xml executable if you want printable
# styled PDF's of tournament brackets.
PRINCE_PATH = nil unless defined?(PRINCE_PATH)
