class Alert < ApplicationRecord
  belongs_to :meter
  belongs_to :alert_type

  has_one :notification_alert
  has_one :notification, through: :notification_alert
end
