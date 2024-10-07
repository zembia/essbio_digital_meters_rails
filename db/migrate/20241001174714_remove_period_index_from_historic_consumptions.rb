class RemovePeriodIndexFromHistoricConsumptions < ActiveRecord::Migration[7.2]
  def change
    remove_column :historic_consumptions, :period_index, :integer
    add_column :historic_consumptions, :month, :date
  end
end
