class RemoveStatemessagesFromAlert < ActiveRecord::Migration[7.2]
  def change
    remove_column :alerts, :statemessages, :string
  end
end
