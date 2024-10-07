class AddFeesToLocations < ActiveRecord::Migration[7.2]
  def change
    add_column :locations, :base_fee, :float
    add_column :locations, :ap_fee, :float
    add_column :locations, :al_fee, :float
    add_column :locations, :tas_fee, :float
    rename_column :locations, :number, :code
  end
end
