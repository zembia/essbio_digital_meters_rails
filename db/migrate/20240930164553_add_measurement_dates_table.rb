class AddMeasurementDatesTable < ActiveRecord::Migration[7.2]
  def change
    create_table :groups do |t|
      t.integer :number
      t.string :description
    end

    create_table :measurement_dates do |t|
      t.references :group, foreign_key: true
      t.date :last_date
      t.date :current_date
      t.timestamps
    end

    add_reference :meters, :group, foreign_key: true, index: true
  end
end
