#!/usr/bin/env ruby

require 'green_shoes'

Dir.chdir(File.join(File.dirname(__FILE__), '..'))

require 'yaml'
require File.join('.', 'lib', 'tournament')

# Define some constants
WINDOW_HEIGHT = 600
WINDOW_WIDTH = 800
BLANK_LABEL = '    '

Shoes.app :width => WINDOW_WIDTH, :height => 600 do
  def load_data
    @entry  = YAML::load_file(@save_file)
  end

  def save_data
    @entry.name = @name.text
    @entry.tie_breaker = @tie_break.text.to_i
    File.open(@save_file, "w") do |f|
      YAML::dump(@entry, f)
    end
  end

  @pool = Tournament::Pool.ncaa_2008

  if ARGV[1]
    @save_file = ARGV[1]
    load_data
  else
    @entry = Tournament::Entry.new
    @entry.picks = Tournament::Bracket.new(@pool.tournament_entry.picks.teams)
    #@picks = Tournament::Bracket.random_bracket(Tournament::Pool.ncaa_2008.bracket.teams)
  end


  @labels = Array.new(4) {Array.new(6) { Array.new }}
  @teams = Array.new(4) {Array.new(6) { Array.new }}
  @buttons = Array.new(4) {Array.new(6) { Array.new }}
  @region_stacks = Array.new(4)
  @champ = Array.new(4)

  def round_stack(region_idx, round, games_per_round, gap, top, width)
    stack :width => width do
      if top > 0
        stack :height => top, :width => 26 do
          background white
        end
      end
      1.upto(games_per_round) do |game|
        bc = game % 2 == 0 || round > 1 ? lightgreen : white
        real_game = game + region_idx * games_per_round
        matchup_flow(region_idx, round, game, real_game, bc, gap)
        if gap > 0
          stack :height => gap, :width => width do
            background white
          end
        end
      end
    end
  end

  def label_for(team, round = 1, game = 1)
    label = if Tournament::Bracket::UNKNOWN_TEAM == team
      "r:%d g:%d" % [round, game]
    else
      if round == 1 || round > 4
        "%2d %s (%s)" % [team.seed, team.name, team.short_name]
      else
        "%4s" % team.short_name
      end
    end
    return label.gsub("&", "&amp;")
  end

  def matchup_flow(region_idx, round, game, real_game, bc, gap)
    @entry.picks.matchup(round,real_game).each_with_index do |team, idx|
      flow do
        background bc
        flow_idx = (game-1)*2 + idx
        @teams[region_idx][round-1][flow_idx] = team
        stack :width => (width - 26) do
          @labels[region_idx][round-1][flow_idx] = para label_for(team, round, game), :height => 26, :width => 175, :font => "Monospace 10px"
        end
        stack :width => 26 do
          @buttons[region_idx][round-1][flow_idx] = button ">", :width => 26, :height => 26, :font => "Monospace 6px", :margin => 1 do
            make_pick(region_idx, round, flow_idx, real_game)
          end
        end
      end
      if gap > 0 && idx == 0
        stack :height => gap, :width => width do
          background bc
        end
      end
    end
  end

  def make_pick(region_idx, round, team_num, real_game)
    team = @teams[region_idx][round-1][team_num]
    return if team == Tournament::Bracket::UNKNOWN_TEAM

    matchup = @entry.picks.matchup(round,real_game).reject{|t| t == team}[0]

    if round == 4
      @champ[region_idx].replace label_for(team, 6, 1)
      #@labels[0][4][region_idx].replace label_for(team, 6, 1)
    end

    if round == 6
      @overall_champ.replace label_for(team, 6, 1)
    end

    forward_round = round
    forward_idx = team_num / 2
    forward_team = @teams[region_idx][forward_round][forward_idx] rescue nil
    while forward_team == matchup
      ri = forward_round > 4 ? 0 : region_idx
      @labels[ri][forward_round][forward_idx].replace BLANK_LABEL
      forward_round += 1
      forward_idx /= 2
      if forward_round == 4
        @champ[region_idx].replace 'Regional Champ'
      end
      if forward_round == 6
        @overall_champ.replace 'NCAA Champion'
      end
      ri = forward_round > 4 ? 0 : region_idx
      fi = forward_round == 5 ? region_idx : forward_idx
      forward_team = @teams[ri][forward_round][fi] rescue nil
    end

    ri = round >= 4 ? 0 : region_idx
    ti = team_num / 2
    if round == 4
      ti = region_idx
    end
    @entry.picks.set_winner(round, real_game, team)
    return if round >= 6
    begin
      @labels[ri][round][ti].replace label_for(team, round+1, real_game)
      @teams[ri][round][ti] = team
    rescue Exception => e
      alert "got error for ri #{ri} round #{round} team_num #{team_num}: #{e}"
    end
  end

  def scrub_save_file
    unless '.yml' == File.extname(@save_file)
      @save_file += '.yml'
    end
  end

  stack :margin => 5 do
    stack do 
      border black, :strokewidth => 1
      flow :margin_bottom => 5 do
        button "Save" do
          if @save_file
            alert("Saving #{@save_file} ...")
          else
            @save_file = ask_save_file
            scrub_save_file
          end
          save_data
        end
        button "Save As ..." do
          @save_file = ask_save_file
          scrub_save_file
          save_data
        end
      end
      stack do
        para "Name"
        @name = edit_line :text => @entry.name
      end
      stack do
        para "Tie Breaker"
        @tie_break = edit_line :text => "#{@entry.tie_breaker}"
      end
    end
    @pool.regions.each_with_index do |region, region_idx|
      @region_stacks[region_idx] = stack do
      stack :margin_bottom => 5 do
        title region[:name]
      end
      flow do
        top = gap = 0
        games_per_round = 16
        1.upto(4) do |round|
          top = top + (round - 1) * 26 / 2
          if round == 4
            top = top + 13
          end
          gap = top * 2
          width = 175
          width = 75 if round > 1
          games_per_round /= 2
          round_stack(region_idx, round, games_per_round, gap, top, width)
        end
        stack :width => 200 do
          stack :height => ((WINDOW_HEIGHT - 226) / 2) do
            background white
          end
          champ = @entry.picks.winner(4, 1 + region_idx)
          champ_label = if champ == Tournament::Bracket::UNKNOWN_TEAM
            'Regional Champ'
          else
            champ.name
          end
          @champ[region_idx] = para champ_label, :font => 'Monospace 10px', :height => 26
        end
        end
      end
    end # regions.each_with_index
    @final_four_stack = stack do
      stack :margin_bottom => 5 do
        title "Final Four"
      end
      flow do
        round_stack(0, 5, 2, 0, 0, 175)
        top = 13
        gap = 26
        round_stack(0, 6, 1, gap, top, 175)
        top = 39
        gap = 78
        stack :width => 175 do
          stack :width => 175, :top => top do
            background white
          end
          stack :width => 175 do
            @overall_champ = para label_for(@entry.picks.champion, 7, 1), :height => 26, :width => 175, :font => "Monospace 10px"
          end
        end
      end
    end
  end
end
