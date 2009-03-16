# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

load 'tasks/setup.rb'

ensure_in_path 'lib'
require 'tournament'

task :default => 'spec:run'

depend_on 'main'
depend_on 'rake'
depend_on 'rails'
depend_on 'sqlite3-ruby'


PROJ.name = 'tournament'
PROJ.authors = 'Douglas A. Seifert'
PROJ.email = 'doug+rubyforge@dseifert.net'
PROJ.url = 'http://www.dseifert.net/code/tournament'
PROJ.rubyforge.name = 'tournament'
PROJ.version = '2.1.1'
PROJ.group_id = 5863

PROJ.spec.opts << '--color'

PROJ.exclude = %w(tmp$ bak$ ~$ CVS \.svn ^pkg ^doc bin/fake bin/gui_v2.rb)
PROJ.exclude << '^tags$'

PROJ.rdoc.opts = ["--line-numbers", "--inline-source"]
PROJ.rdoc.template = "tasks/jamis.rb"
# EOF
