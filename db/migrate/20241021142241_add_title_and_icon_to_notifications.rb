class AddTitleAndIconToNotifications < ActiveRecord::Migration[7.2]
  def change
    add_column :notifications, :title, :string
    add_column :notifications, :icon, :string
  end
end
