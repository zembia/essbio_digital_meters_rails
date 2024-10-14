class RenameUserNotifications < ActiveRecord::Migration[7.2]
  def change
    remove_reference :user_notifications, :user, foreign_key: true
    rename_table :user_notifications, :client_notifications
    add_reference :client_notifications, :client, foreign_key: true
    add_reference :client_notifications, :meter, null: true, foreign_key: true
  end
end
