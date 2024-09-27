class RenameConsumptions < ActiveRecord::Migration[7.2]
  def change
    rename_table :cosumptions, :consumptions
  end
end
