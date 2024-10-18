class ClientNotification < ApplicationRecord
  belongs_to :notification
  belongs_to :client
  belongs_to :meter, optional: true

  has_many :notification_alerts
  has_many :alerts, through: :notification_alerts

  def level
    notification.level
  end

end
