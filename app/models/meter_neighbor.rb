class MeterNeighbor < ApplicationRecord
  belongs_to :meter
  belongs_to :neighbor, class_name: 'Meter'
end
