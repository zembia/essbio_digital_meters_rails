class AddMonthToMeasurementDates < ActiveRecord::Migration[7.2]
  def change
    add_column :measurement_dates, :month, :date
  end
end
