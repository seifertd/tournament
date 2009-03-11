class Seeding < ActiveRecord::Base
  belongs_to :team
  belongs_to :pool
end
