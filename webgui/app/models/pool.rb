
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
  has_many :seedings
  has_many :teams, :through => :seedings
  has_many :regions, :order => 'position'

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

  # True if the number of teams in the pool is 64
  def ready?
    return teams.size == 64
  end

  def region_seedings
    reg_ret = self.regions.inject([]) do |arr, r|
      arr[r.position] = [r.name, Array.new(16)]
      arr
    end
    (0..3).each {|n| reg_ret[n] ||= ['', Array.new(16)]}

    self.seedings.each_with_index do |t, idx|
      region = reg_ret.find {|name, teams| name == t.region} || reg_ret.find {|name, teams| name.blank?}
      region[0] = t.region
      region[1][t.seed-1] = t.team
    end
    return reg_ret
  end

  def entries_for(user)
    entries.find_all_by_user_id(user.id)
  end

  def initialize_tournament_pool
    if self.ready?
      @pool = Tournament::Pool.new
      @pool.scoring_strategy = FormObject.class_get(@scoring_strategy || 'Tournament::ScoringStrategy::Basic').new
      region_counter = 0
      self.region_seedings.each do |region_name, seedings|
        # Reorder ... #TODO: Configuration?
        seedings = [1,16,8,9,5,12,4,13,6,11,3,14,7,10,2,15].map {|seed| [seedings[seed-1], seed] }
        @pool.add_region(region_name,
          seedings.map { |t, seed| Tournament::Team.new(t.name, t.short_name, seed) },
          region_counter)
        region_counter += 1
      end
      # Resolve the bracket
      @pool.bracket
    else
      @pool = Tournament::Pool.new
    end
  end

  def pool
    unless @pool
      if self[:data]
        @pool = Marshal.load(self[:data])
      else 
        initialize_tournament_pool
      end
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
    self.pool.scoring_strategy = FormObject.class_get(@scoring_strategy).new if @scoring_strategy
    self.pool.entry_fee = @fee
    self.pool.payouts.clear
    if @payouts
      @payouts.each do |po|
        next unless po.kind && po.rank && po.payout
        amount = po.kind == '$' ? -po.payout : po.payout
        rank = po.rank == 'L' ? :last : po.rank
        self.pool.set_payout(rank, amount)
      end
    end
    self[:data] = Marshal.dump(@pool)
  end

  def after_initialize
    @payouts = []
    return unless self.pool
    self.fee = self.pool.entry_fee
    self.scoring_strategy = self.pool.scoring_strategy.class.name
    self.pool.payouts.each do |rank, payout|
      next unless rank && payout
      rank = rank == :last ? 'L' : rank.to_s
      kind = payout < 0 ? '$' : '%'
      payout = payout.abs
      @payouts << PayoutData.new(:rank => rank, :payout => payout, :kind => kind)
    end
    @payouts << PayoutData.new
  end

  def accepting_entries?
    return ready? && Time.now < starts_at
  end

  def self.active_pools
    Pool.find(:all, :conditions => ['active = ?', true])
  end
end
