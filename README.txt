tournament
    by Douglas A. Seifert (doug+rubyforge at dseifert dot net)
    http://www.dseifert.net/code/tournament
    http://tournament.rubyforge.org/

== DESCRIPTION:

Small library and command line program for managing a NCAA
basketball tournament pool.

== FEATURES/PROBLEMS:

* Add NCAA tournament pool entries and save them as YAML
* Run a possibilities report for determining who is likely to win
* Run other reports such as a leader board and entry report
* Buggy, but functional, Shoes GUI included for creating the entries
  and updating the tournament results bracket.
* FIXME: Write a test suite.

== SYNOPSIS:

The tournament command line program is installed as 'tournament'.  The library
has the 2008 NCAA tournament pre-configured.  If you were to use
this library for the 2009 NCAA tournament, code changes would be
necessary. FIXME (add ability to read teams from a simple configuration
file).  

The pool manager would use this program as follows:

 1. Choose a scoring strategy.  There are various scoring strategies
    that could be used.  The library comes pre-configured with 
    two scoring strategies:
    
    1. Basic scoring strategy: each correct pick is worth 2 X the round.
    2. Upset favoring strategy: each correct pick is worth a
       base amount per round plus the seed number of the winner.  As
       pre-configured, the base amounts per round are 3, 5, 11, 19, 30
       and 40 points.

    If your scoring strategy is not one of the above, you will have to
    write a class in the Bracket class, in file lib/tournament/bracket.rb.

 2. Initialize the pool

    tournament setup pool.yml [--scoring=upset_scoring_strategy]

    Use the --scoring argument to change to the upset favoring 
    strategy.  If the basic strategy is ok, the --scoring argument is
    not required.

 3. Export a tournament entry YAML file

    tournament bracket pool.yml tournament.yml

 4. Create entries.  You can use the included buggy GUI (see below),
    or edit YAML files by hand.

 5. Import the entry YAML files into the pool

    tournament update pool.yml --add-entry=path/to/entry.yml

 6. As games progress, update the tournament.yml file, again using the GUI or
    editing the YAML file by hand.  Then update the pool with the new
    tournament YAML file

    tournament update pool.yml --bracket=tournament.yml

 7. Run reports
  
    tournament report pool.yml --type=[entry|region|leader|score]

 8. After about 22 teams are left, run a possibility report.  This report will
    run through all the remaining ways the tournament can come out and
    calculate the chance to win for each player.  The chance to win
    is defined as the percentage of possibilities that lead to that player
    coming out on top in the pool.  With more than about 22 teams left
    (YMMV), this report could take months to run. FIXME (Investigate
    possibly using EC2 or something to spread the load around, or 
    otherwise optimize the possibility checking algorithm)

    tournament report pool.yml --type=possibility

== SHOES GUI:

A GUI for filling out tournment bracket entries is included and is run
by executing the program "picker".  If no argument is included, a blank
entry is started.  It can be filled in and saved using one of the buttons
at the top of the screen.  The entry is saved as a YAML file for a
Tournament::Entry object.   The picker program optionally takes one
argument, the path to a Tournament::Entry YAML file.  It will open
with the provided entry's picks pre filled in.

The GUI may be used for keeping the NCAA tournament entry YAML file
up to date.
 
== REQUIREMENTS:

* main (2.8.0)
* shoes-0.r396 (GUI Only)

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
