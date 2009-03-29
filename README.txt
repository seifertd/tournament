tournament
    by Douglas A. Seifert (doug+rubyforge at dseifert dot net)
    http://www.dseifert.net/code/tournament
    http://tournament.rubyforge.org/

== DESCRIPTION:

Small library, command line program and Rails web GUI for managing a NCAA
basketball tournament pool.

== FEATURES/PROBLEMS:

* Fully functional, self-service web GUI for collecting entries and
  generating reports
* Or use command line to add NCAA tournament pool entries and save them as YAML
* Run a possibilities report for determining who is likely to win
* Run other reports such as a leader board and entry report
* [DEPRECATED] Buggy, but functional, Shoes GUI included for creating
  the entries and updating the tournament results bracket.  Useful as an
  adjunct to the command line script.
* FIXME: Complete the test suite for the library and command line tool

== COMMAND LINE SYNOPSIS:

The tournament command line program is installed as 'pool'.  The library
has the 2009 NCAA tournament pre-configured.  If you were to use
this library for the 2010 NCAA tournament, code changes would be
necessary. FIXME: (add ability to read teams from a simple configuration
file).  For usage, just execute

   pool --help

For command specific usage, execute

   pool [command] --help

where [command] is one of the available commands described below. The
pool command saves state in a file called pool.yml by default.  This
can be overridden in all cases by using the --save-file option.

The pool manager would use this program as follows:

1. Choose a scoring strategy.  There are various scoring strategies
   that could be used.  The library comes pre-configured with 
   three scoring strategies:
   1. Basic scoring strategy: each correct pick is worth 2 X the round.
   2. Upset favoring strategy: each correct pick is worth a
      base amount per round plus the seed number of the winner.  As
      pre-configured, the base amounts per round are 3, 5, 11, 19, 30
      and 40 points.
   3. The Josh Patashnik strategy: each correct pick is worth the
      winner's seed number X a round multiplier.  The multipliers
      are 1, 2, 4, 8, 16 and 32 points.
   4. Tweaked Josh Patashnik strategy: each correct pick is worth the
      winner's seed number X a round multiplier.  The multipliers
      are 1, 2, 4, 8, 12 and 22 points.
   4. Constant Value strategy: each correct pick is worth exactly
      one (1) point, regardless of round.
   If your scoring strategy is not one of the above, you will have to
   add a class to the ScoringStrategy module, in file
   lib/tournament/scoring_strategy.rb.

2. Create a directory to hold the pool data and change to it

3. Initialize the pool

       pool setup [--scoring=upset]

   Use the --scoring argument to change from the default basic scoring
   strategy.  If the basic strategy is ok, the --scoring argument is
   not required.

   As mentioned above, unless overridden by using the --save-file
   option, the pool will save itself to the file 'pool.yml'

4. Set the entry fee and payout amounts
   
       pool fee 10
       pool payout 1 80
       pool payout 2 20
       pool payout last 10 -C

   The above commands say that each entry fee is 10 units (this is all
   for fun, not profit, right?) and that the 1st place finisher would
   receive 80% of the total payout, the 2nd place finisher would 
   receive 20% of the total payout and the last place finisher would
   receive 10 units back (would get her entry fee back).  No error
   checking is done with this.  FIXME: Add error checking.

5. Export a tournament entry YAML file

       pool dump

   This will save the tournament entry file as tournament.yml unless
   the --entry option is used to override it.

6. Create entries.  You can use the included buggy GUI (see below),
   or edit YAML files by hand.

7. Import the entry YAML files into the pool

       pool entry --add=path/to/entry.yml

8. As games progress, update the tournament.yml file, again using the GUI or
   editing the YAML file by hand.  Then update the pool with the new
   pool YAML file

       pool update

9. Run reports
  
       pool report [final_four|entry|region|leader|score]

   The final four report can only be run once the final four teams have
   been determined.

10. After about 22 teams are left, run a possibility report.  This report will
    run through all the remaining ways the tournament can come out and
    calculate the chance to win for each player.  The chance to win
    is defined as the percentage of possibilities that lead to that player
    coming out on top in the pool.  With more than about 22 teams left
    (YMMV), this report could take months to run. FIXME (Investigate
    possibly using EC2 or something to spread the load around, or 
    otherwise optimize the possibility checking algorithm)

        pool report possibility

== WEB GUI:

A Rails web application is available if you don't want to use the
command line to manage your pool.

=== INSTALLING THE WEB GUI:

The web application can be installed by running the pool command
as follows

   pool install_webgui --web-dir=/path/to/directory [options]

The above command will copy the Rails app to the specified directory.

There are several options you can provide in addition to --web-dir
to control how the application is installed:

* Human readable site name.  This appears as the title tag content
  of pages in the site and is also used in the subject line of any
  emails sent by the site (as during user registration).

    --site-name="Site Name"  (Default: 'Tournament')

* Relative url root.  If you will be installing the pool site as
  a relative url on another virtual host, use this switch.  You
  will have to configure you virtual host to route requests to this
  path to Rails.  This is ridiculously easy if you are using
  modrails and Apache.  Example:

    --relative-root=/my_pool  (Default: empty, no root is set)
 
* Administrator email address.  The web GUI will send emails
  when users register for creating entries in a pool. The following
  sets the from email address on the emails that are sent.

    --admin-email=admin

* Email server information.  Either edit the config/initializers/pool.rb
  file after installation, or provide the following options to configure
  a SMTP server available on your domain.

    --email-server=smtp.myisp.com
    --email-port=25
    --email-domain=mydomain.com
    --email-user=myuser
    --email-password=mypass
    --email-auth=login|plain|cram_md5

  See http://guides.rubyonrails.org/action_mailer_basics.html#_action_mailer_configuration
  for more info on how to configure a Rails app for sending email.

* The web GUI has the ability to print bracket entries by generating
  a pdf styled using the web site's bracket stylesheet.  It uses a third
  party tool called Prince XML to do this.  You are not allowed to
  use this on a server without paying a license fee, although you
  can download a trial version for personal use.  It's your call
  whether or not you want to use this.  Please see http://www.princexml.com/
  for more details.
 
    --use-princexml=/full/path/to/prince

  If prince is not available on the path you specify, the princexml
  distribution will be downloaded and installed using the distribution's
  install.sh script.  In order to do this, the tar program must be
  available on your installation system.

* If you use the --use-princexml option, the install script needs to write
  files to a temp directory, /tmp by default. Use the --tmp-dir option to
  change this default.  If the specified temp dir does not exist, it will
  be created.

    --tmp-dir=/path/to/tmp/dir

=== POST-INSTALLATION:

Before being able to run the web gui for the first time, you have to
generate the web site authorization keys, prepare the sqlite database
and create an admin account.  Change to the website installation
directory and perform the following steps.

1. Generate the web site authorization keys

     RAILS_ENV=production rake auth:gen:site_key

2. Prepare the sqlite database

     RAILS_ENV=production rake db:migrate

3. Create the admin account

     RAILS_ENV=production rake "admin:create[login,email,name,password]"

   In the above command, substitute "login" for the desired admin user's login
   name, "email" for the administrators email address, "name" for the 
   admin user's name (eg, "Joe Admin"), and "password" for the desired
   admin account password

=== UPDATING THE WEB GUI:

If the tournament gem is updated, you can pull in the changes as follows:

1. Update your tournament gem

     sudo gem update tournament

2. Rerun the same pool install_webgui command you used to install originally

3. Pull in any released db migrations:

     cd $install_dir; RAILS_ENV=production rake db:migrate

4. Reload your web server configuration (nginx, apache, etc.)

=== USING THE WEB GUI:

Load the entry page in your brower.  Log in as the admin user you 
configured during installation.  Click on on the 'All Pools' link on
the right sidebar.  Create a new pool and fill in the information.
Each time you save this form, a new blank payouts line will be added
so that you can configure as many payouts as you desire.

After the basic pool configuration is set up, click on the 'Teams'
link in the right sidebar.  You are presented with four region
brackets to fill in.  Keep in mind that the pink region champs will
play each other in the final four and the light blue region champs
will play each other in the final four so you can get the bracket 
right.  The web application is preconfigured with over 300 NCAA
schools.  The team name fields are auto-complete fields -- type in
a few letters and pause and you will be presented with a list of
matching teams.  The Short Name field should be a three letter
abbreviation for the team.  The abbreviations have to be unique
across the entire tournament field.

Once the teams are configured, go back to the pool basic information
form, click the Active check box and save the form.  The pool is now
ready for entries to be added to it.  Invite your friends to join the pool
by giving them the url for the entry page.  They will be asked to
register.  After registering and logging in, they will be able to
submit entries to your pool.

As the tournament progresses, use the 'Tournament Bracket' link
on the right sidebar to record the winning teams.  

Use the report links to run reports, etc.

==== POSSIBILITY REPORT

After about 21 teams are left in the tournament, you can run the
possibility report.  This report runs through every possible way the
tournament can come out and ranks each entry against the possiblity.
The report lists the "chance to win" for each entry.  The chance
to win is the percentage of possible outcomes that would result in
that entry coming in first.

The possibility report requires that a rake task be run on the
web server.  It is very processor intensive and can take a long
time to complete.  To generate the possibility report data file,
run the following command from the web gui install directory
on the server:

   RAILS_ENV=production rake report:possibilities

== SHOES GUI:

A GUI for filling out tournment bracket entries is included and is run
by executing the program "picker".  If no argument is included, a blank
entry is started.  It can be filled in and saved using one of the buttons
at the top of the screen.  The entry is saved as a YAML file for a
Tournament::Entry object.   The picker program optionally takes one
argument, the path to a Tournament::Entry YAML file.  It will open
with the provided entry's picks pre filled in.

The GUI also may be used for keeping the NCAA tournament entry YAML file
up to date:

   picker tournament.yml

The GUI works as long as you don't try to go back and change games
from played to unknown outcome.
 
== REQUIREMENTS:

* main (2.8.0)

== WEB GUI REQUIREMENTS:

* rails (2.2.2)
* rake (0.8.3)
* sqlite3-ruby (1.2.4)

== SHOES GUI REQUIREMENTS:

Verified working on
* shoes raisins v1134

== INSTALL:

* sudo gem install tournament
* Download the tgz file and run it locally.  If the latter
  option is taken, the tournament/bin directory must be in
  the path.

== LICENSE:

(The MIT License)

Copyright (c) 2008

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
