class ClientNotification < ApplicationRecord
  belongs_to :notification
  belongs_to :client
  belongs_to :meteri, optional: true
end
