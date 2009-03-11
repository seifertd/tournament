class Role < ActiveRecord::Base
  acts_as_enumerated :order => 'position asc'
  has_and_belongs_to_many :users
end
