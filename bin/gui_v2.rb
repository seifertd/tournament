#!/usr/bin/env shoes

require 'yaml'
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'tournament.rb'))

# Define some constants
WINDOW_HEIGHT = 600
WINDOW_WIDTH = 800
BLANK_LABEL = '    '

class Picker < Shoes
  url '/', :index
  url '/save', :save
  url '/load', :load
  url '/final4', :final4

  def init
    if ARGV[1]
      @save_file = ARGV[1]
      load_data
    else
      @pool = Tournament::Pool.ncaa_2008
      #@picks = Tournament::Bracket.new(@pool.bracket.teams)
      @picks = Tournament::Bracket.random_bracket(Tournament::Pool.ncaa_2008.bracket.teams)
    end
    @labels = Array.new(4) {Array.new(6) { Array.new }}
    @teams = Array.new(4) {Array.new(6) { Array.new }}
    @buttons = Array.new(4) {Array.new(6) { Array.new }}
    @champ = Array.new(4)
    @pool.regions.each_with_index do |region, region_idx|
      self.class.url "/(#{region[:name].downcase})", :region
    end
  end

  def load_data
    if @save_file
      @pool, @picks  = YAML::load_file(@save_file)
    end
  end

  def save_data
    File.open(@save_file, "w") do |f|
      YAML::dump([@pool, @picks], f)
    end
  end

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
      if round == 1
        "%2d %s (%s)" % [team.seed, team.name, team.short_name]
      else
        "%4s" % team.short_name
      end
    end
  end

  def matchup_flow(region_idx, round, game, real_game, bc, gap)
    @picks.matchup(round,real_game).each_with_index do |team, idx|
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

    if round == 4
      @champ[region_idx].replace team.name
      @labels[0][4][region_idx].replace team.name
      # Check championship game
      if @teams[0][5][region_idx/2] != team
        @teams[0][5][region_idx/2] = Tournament::Bracket::UNKNOWN_TEAM
        @labels[0][5][region_idx/2] = BLANK_LABEL
      end
      # Check Champ
      @teams[region_idx][4][0] = team
      @picks.set_winner(round, real_game, team)
      return
    end

    forward_round = round
    forward_idx = team_num / 2
    forward_team = @teams[region_idx][forward_round][forward_idx]
    while forward_team != Tournament::Bracket::UNKNOWN_TEAM
      @labels[region_idx][forward_round][forward_idx].replace BLANK_LABEL
      forward_round += 1
      forward_idx /= 2
      if forward_round > 3
        @champ[region_idx].replace 'Regional Champ'
        @teams[region_idx][4][0] = Tournament::Bracket::UNKNOWN_TEAM
        break
      end
      forward_team = @teams[region_idx][forward_round][forward_idx]
    end

    @picks.set_winner(round, real_game, team)
    @labels[region_idx][round][team_num/2].replace team.short_name
    @teams[region_idx][round][team_num/2] = team
  end

  def scrub_save_file
    unless '.yml' == File.extname(@save_file)
      @save_file += '.yml'
    end
  end

  def left_nav
    stack :margin => 10, :width => 90 do
      background lightgreen
      border black
      para link("load", :click => "/load")
      para link("save", :click => "/save")
      @pool.regions.each do |region|
        para link(region[:name], :click => "/#{region[:name].downcase}")
      end
      para link("Final 4", :click => "/final4")
    end
  end

  def index
    self.init
    self.left_nav
  end

  def save
    if @save_file
      alert("Saving #{@save_file} ...")
    else
      @save_file = ask_save_file
      scrub_save_file
    end
    save_data
    index
  end

  def load
    @save_file = ask_open_file
    load_data
    index
  end

  def region(region_name)
    self.init
    self.left_nav
    region = @pool.regions.find {|r| r[:name].downcase == region_name}
    region_idx = @pool.regions.index(region)
    stack :width => (WINDOW_WIDTH - 100) do
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
          champ = @picks.winner(4, 1 + region_idx)
          champ_label = if champ == Tournament::Bracket::UNKNOWN_TEAM
            'Regional Champ'
          else
            champ.name
          end
          @champ[region_idx] = para champ_label, :font => 'Monospace 10px', :height => 26
        end
      end
    end
  end

  def all
  stack :margin => 5 do
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
            @overall_champ = para label_for(@picks.champion, 7, 1), :height => 26, :width => 175, :font => "Monospace 10px"
          end
        end
      end
    end
    @final_four_stack.hide
    @pool.regions.each_with_index do |region, region_idx|
      stack do
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
          champ = @picks.winner(4, 1 + region_idx)
          champ_label = if champ == Tournament::Bracket::UNKNOWN_TEAM
            'Regional Champ'
          else
            champ.name
          end
          @champ[region_idx] = para champ_label, :font => 'Monospace 10px', :height => 26
        end
        end
      end
      @region_stacks[region_idx].hide() if region_idx > 0
    end # regions.each_with_index
  end
  end
end

Picker.new
Shoes.app :width => WINDOW_WIDTH, :height => 600
