class AddLevelToNotifications < ActiveRecord::Migration[7.2]
  def change
    add_column :notifications, :level, :integer
  end
end
