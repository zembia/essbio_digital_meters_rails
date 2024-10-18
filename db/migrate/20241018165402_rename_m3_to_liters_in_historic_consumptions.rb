class RenameM3ToLitersInHistoricConsumptions < ActiveRecord::Migration[7.2]
  def change
    rename_column :historic_consumptions, :m3, :liters
  end
end
