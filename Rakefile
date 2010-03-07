
begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

ensure_in_path 'lib'
require 'tournament'

task :default => 'test:run'

Bones {
  depend_on 'main'
  depend_on 'rake'
  depend_on 'rails'

  name 'tournament'
  authors 'Douglas A. Seifert'
  email 'doug+rubyforge@dseifert.net'
  url 'http://www.dseifert.net/code/tournament'
  rubyforge.name 'tournament'
  version Tournament::VERSION
  group_id = 5863

#spec.opts << '--color'

  exclude %w(tmp$ bak$ ~$ CVS \.svn ^pkg ^doc bin/fake bin/gui_v2.rb ^tags$)

  rdoc.opts ["--line-numbers", "--force-update", "-W", "http://tournament.rubyforge.org/svn/trunk/%s"]
  rdoc.exclude [
    "webgui\/vendor\/plugins\/restful_authentication\/notes\/.+\.txt",
    "webgui\/db\/migrate\/teams.txt",
    "webgui\/public\/robots.txt"
  ]
}
