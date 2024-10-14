class AddClpToHistoricConsumptions < ActiveRecord::Migration[7.2]
  def change
    add_column :historic_consumptions, :clp, :float
    rename_column :historic_consumptions, :value, :m3
  end
end
