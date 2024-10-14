class AddTagToNotificationTypes < ActiveRecord::Migration[7.2]
  def change
    add_column :notification_types, :tag, :string
  end
end
