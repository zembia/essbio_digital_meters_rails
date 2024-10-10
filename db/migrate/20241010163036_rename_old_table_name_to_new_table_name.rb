class RenameOldTableNameToNewTableName < ActiveRecord::Migration[7.2]
  def change
    rename_table :neighbors, :meter_neighbors
  end
end
