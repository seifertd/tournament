class Team < ActiveRecord::Base
  validates_uniqueness_of :name
  validates_uniqueness_of :short_name
  has_many :seedings
  has_many :pools, :through => :seedings
end
