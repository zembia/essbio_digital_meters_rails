class AddStatusToClientNotifications < ActiveRecord::Migration[7.2]
  def change
    add_column :client_notifications, :status, :string
  end
end
