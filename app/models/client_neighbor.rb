class ClientNeighbor < ApplicationRecord
  belongs_to :client
  belongs_to :neighbor, class_name: 'Client'
end
