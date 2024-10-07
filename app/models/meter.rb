class Meter < ApplicationRecord
  has_many :consumptions
  has_many :historic_consumptions
  has_one :data_summary
  belongs_to :group
  belongs_to :location
end
