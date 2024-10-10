class AddLatLongToMaestroclientes < ActiveRecord::Migration[7.2]
  def change
    add_column :maestroclientes, :latitud, :float
    add_column :maestroclientes, :longitud, :float

    add_column :meters, :lat, :float
    add_column :meters, :long, :float
  end
end
