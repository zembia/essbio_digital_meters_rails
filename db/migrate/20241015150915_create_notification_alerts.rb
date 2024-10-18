class CreateNotificationAlerts < ActiveRecord::Migration[7.2]
  def change
    create_table :notification_alerts do |t|
      t.references :client_notification, null: false, foreign_key: true
      t.references :alert, null: false, foreign_key: true

      t.timestamps
    end
  end
end
