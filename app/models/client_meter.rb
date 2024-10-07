class ClientMeter < ApplicationRecord
  belongs_to :meter
  belongs_to :client
end
