# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

load 'tasks/setup.rb'

ensure_in_path 'lib'
require 'tournament'

task :default => 'spec:run'

depend_on 'main'

PROJ.name = 'tournament'
PROJ.authors = 'Douglas A. Seifert'
PROJ.email = 'doug+rubyforge@dseifert.net'
PROJ.url = 'http://www.dseifert.net/code/tournament'
PROJ.rubyforge_name = 'tournament'
PROJ.version = '1.0.0'
PROJ.group_id = 5863

PROJ.spec_opts << '--color'

PROJ.exclude = %w(tmp$ bak$ ~$ CVS \.svn ^pkg ^doc bin/fake bin/gui_v2.rb)
PROJ.exclude << '^tags$'

PROJ.rdoc_opts = ["--line-numbers", "--inline-source"]
PROJ.rdoc_template = "tasks/jamis.rb"

# EOF
