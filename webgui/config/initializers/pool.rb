require 'tournament'

TOURNAMENT_TITLE = "2009 NCAA Tournament"

$pool = Tournament::Pool.ncaa_2008
$pool.bracket.set_winner(1,1,$pool.bracket.teams[1])
