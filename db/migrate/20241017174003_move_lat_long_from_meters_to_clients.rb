class MoveLatLongFromMetersToClients < ActiveRecord::Migration[7.2]
  def change
    remove_column :maestroclientes, :latitud, :float
    remove_column :maestroclientes, :longitud, :float

    remove_column :meters, :lat, :float
    remove_column :meters, :long, :float

    add_column :clients, :lat, :float
    add_column :clients, :long, :float
  end
end
