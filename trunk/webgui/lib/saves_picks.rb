module SavesPicks
  def save_picks(entry)
    bracket = entry.bracket
    picks = params[:picks]
    logger.debug("PICKS: #{picks}")
    picks.split(//).each_with_index do |pick, idx|
      round, game = bracket.round_and_game(idx+1)
      logger.debug("Round #{round} game #{game} pick #{pick} idx #{idx}")
      if pick != '0'
        pick = pick.to_i - 1
        team = bracket.matchup(round, game)[pick]
        logger.debug("      --> Team = #{team.name}")
        bracket.set_winner(round, game, team)
      else
        bracket.set_winner(round, game, Tournament::Bracket::UNKNOWN_TEAM) 
      end
    end
    logger.debug("SAVING ENTRY PARAMS: #{params[:entry].inspect}")
    entry.attributes = params[:entry]
    logger.debug("DONE SAVING ENTRY PARAMS")
    entry.completed = true if bracket.complete?
  end
end
