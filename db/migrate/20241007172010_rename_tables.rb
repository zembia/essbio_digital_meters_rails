class RenameTables < ActiveRecord::Migration[7.2]
  def change
    rename_table :user_meters, :client_meters
    rename_table :consumptions_per_hour, :consumos_por_hora
    add_column :consumos_por_hora, :fecha_hora, :datetime
  end
end
