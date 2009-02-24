class AdminController < ApplicationController
  before_filter :login_required
  include SavesPicks

  # Class for collecting payout info
  class PayoutData < FormObject
    attr_accessor :rank, :payout, :kind
    validates_presence_of :rank
    validates_presence_of :payout
    validates_presence_of :kind
    validates_numericality_of :payout
    validates_format_of :rank, :with => /\A[L\d]\Z/
    def payout_before_type_cast
      @payout
    end
    def _delete
      false
    end
  end
  # Class for collecting pool admin inputs
  class PoolData < FormObject
    attr_accessor :scoring_strategy
    attr_reader :payouts
    attr_accessor :fee

    validates_presence_of :scoring_strategy
    validates_length_of :payouts, :minimum => 1, :message => "There must be at least 1 payout."

    def initialize(attrs = {})
      if attrs.empty?
        @scoring_strategy = $pool.bracket.scoring_strategy.class.name
        @fee = $pool.entry_fee
        @payouts = []
        $pool.payouts.each do |rank, payout|
          rank = rank == :last ? 'L' : rank.to_s
          kind = payout < 0 ? '$' : '%'
          payout = payout.abs
          @payouts << PayoutData.new(:rank => rank, :payout => payout, :kind => kind)
        end
        @payouts << PayoutData.new
      end
      super 
    end

    def payouts=(new_payouts)
      @payouts ||= []
      new_payouts.each do |idx, hash|
        idx = idx.to_i
        next if hash['payout'].blank? && hash['rank'].blank?
        next if hash['_delete'] == '1'
        amount = hash['payout'].to_i
        rank = hash['rank'] == 'L' ? hash['rank'] : hash['rank'].to_i
        @payouts[idx] = PayoutData.new(:rank => rank, :payout => amount, :kind => hash['kind'])
      end
      @payouts.compact!
    end

    def valid?
      val = super
      @payouts.each do |po|
        val = val && po.valid?
      end
      return val
    end

    def save
      $pool.bracket.scoring_strategy = FormObject.class_get(@scoring_strategy).new
      $pool.entry_fee = @fee
      $pool.payouts.clear
      @payouts.each do |po|
        amount = po.kind == '$' ? -po.payout : po.payout
        rank = po.rank == 'L' ? :last : po.rank
        $pool.set_payout(rank, amount)
      end
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
      if @pool.valid?
        @pool.save
        @pool = PoolData.new
      end
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
