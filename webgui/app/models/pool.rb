
class Pool < ActiveRecord::Base
  attr_accessor :fee, :scoring_strategy
  attr_reader :payouts
  validates_uniqueness_of :name
  before_save :marshal_pool
  belongs_to :user
  has_many :entries
  has_many :user_entries, :class_name => 'Entry', :conditions => ['user_id != ?', '#{user_id}']
  has_many :pending_entries, :class_name => 'Entry', :conditions => ['completed = ? and user_id != ?', false, '#{user_id}']
  has_one :tournament_entry, :class_name => 'Entry', :conditions => {:user_id => '#{user_id}'}

  # Class for collecting payout info from edit pool form
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

  def entries_for(user)
    entries.find_all_by_user_id(user.id)
  end

  def pool
    unless @pool
      if self[:data]
        @pool = Marshal.load(self[:data])
      else 
        @pool = Tournament::Pool.ncaa_2008
      end
      @pool.bracket
    end
    @pool
  end

  def payouts=(new_payouts)
    @payouts = []
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

  def marshal_pool
    self.pool.bracket.scoring_strategy = FormObject.class_get(@scoring_strategy).new
    self.pool.entry_fee = @fee
    self.pool.payouts.clear
    @payouts.each do |po|
      next unless po.kind && po.rank && po.payout
      amount = po.kind == '$' ? -po.payout : po.payout
      rank = po.rank == 'L' ? :last : po.rank
      self.pool.set_payout(rank, amount)
    end
    self[:data] = Marshal.dump(@pool)
  end

  def after_initialize
    return unless self.pool
    self.fee = self.pool.entry_fee
    self.scoring_strategy = self.pool.bracket.scoring_strategy.class.name
    @payouts = []
    self.pool.payouts.each do |rank, payout|
      next unless rank && payout
      rank = rank == :last ? 'L' : rank.to_s
      kind = payout < 0 ? '$' : '%'
      payout = payout.abs
      @payouts << PayoutData.new(:rank => rank, :payout => payout, :kind => kind)
    end
    @payouts << PayoutData.new
  end

  def self.active_pools
    Pool.find(:all, :conditions => {:active => true})
  end
end
