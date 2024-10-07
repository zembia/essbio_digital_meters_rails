class Group < ApplicationRecord
  has_many :meters
  has_many :measurement_dates
end
