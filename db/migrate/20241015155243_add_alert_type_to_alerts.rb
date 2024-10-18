class AddAlertTypeToAlerts < ActiveRecord::Migration[7.2]
  def change
    add_reference :alerts, :alert_type, null: false, foreign_key: true
  end
end
