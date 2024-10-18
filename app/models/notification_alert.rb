class NotificationAlert < ApplicationRecord
  belongs_to :alert
  belongs_to :client_notification
end
