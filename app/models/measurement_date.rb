class MeasurementDate < ApplicationRecord
  has_many :meters
  belongs_to :group
end
