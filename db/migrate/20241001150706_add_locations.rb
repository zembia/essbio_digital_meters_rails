class AddLocations < ActiveRecord::Migration[7.2]
  def change
    create_table :locations do |t|
      t.integer :number, index: true
      t.string :name
      t.timestamps
    end

    add_reference :meters, :location, foreign_key: true, index: true
  end
end
