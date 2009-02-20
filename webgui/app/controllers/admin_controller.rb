class AdminController < ApplicationController
  before_filter :login_required
  include SavesPicks

  # Class for collecting payout info
  class PayoutData < FormObject
    attr_accessor :rank, :payout
    validates_presence_of :rank
    validates_presence_of :payout
    validates_numericality_of :payout
  end
  # Class for collecting pool admin inputs
  class PoolData < FormObject
    attr_accessor :scoring_strategy
    attr_accessor :payouts

    validates_presence_of :scoring_strategy
    validates_length_of :payouts, :minimum => 1, :message => "There must be at least 1 payout."

    def initialize(attrs = {})
      if attrs.empty?
        @scoring_strategy = $pool.bracket.scoring_strategy.class.name
        @payouts = []
        $pool.payouts.each do |rank, payout|
          @payouts << PayoutData.new(:rank => rank, :payout => payout)
        end
      end
      super 
    end

    def save
      $pool.bracket.scoring_strategy = FormObject.class_get(@scoring_strategy).new
      Tournament.save_pool
    end

  end

  def edit
    @entry = Entry.find_by_user_id(current_user.id)
    if @entry
      save_picks(@entry)
      if @entry.save
        $pool.bracket = @entry.bracket
        Tournament.save_pool
        flash[:info] = "Tournament bracket updated."
        redirect_to :action => 'bracket'
      else
        flash[:error] = "Could not save entry."
        render :action => 'bracket', :layout => 'bracket'
      end
    else
      flash[:error] = "Tournament bracket has not yet been initialized."
    end
  end

  def entries
  end

  def reports
  end

  def pool
    @available_scoring_strategies = Tournament::Bracket.available_strategies.map{|n| Tournament::Bracket.strategy_for_name(n)}
    if request.get?
      @pool = PoolData.new
    else
      @pool = PoolData.new(params[:pool])
      @pool.save
    end
  end

  def bracket
    @entry = Entry.find_or_initialize_by_user_id(:user_id => current_user.id, :tie_break => 0, :name => 'Tournament Bracket')
    @entry.bracket
    @entry.save!
      
    render :layout => 'bracket'
  end

  def authorized?(action = action_name, resource = nil)
    super && current_user.roles.include?(Role[:admin])    
  end

end
