# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

load 'tasks/setup.rb'

ensure_in_path 'lib'
require 'tournament'

task :default => 'spec:run'

PROJ.name = 'tournament'
PROJ.authors = 'Douglas A. Seifert'
PROJ.email = 'doug at dseifert dot net'
PROJ.url = 'http://www.dseifert.net/code/ncaa_pool'
PROJ.rubyforge_name = 'tournament'

PROJ.spec_opts << '--color'

# EOF
