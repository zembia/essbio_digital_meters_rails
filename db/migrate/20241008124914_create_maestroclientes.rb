class CreateMaestroclientes < ActiveRecord::Migration[7.2]
  def change
    create_table :maestroclientes do |t|
      t.string :deveui
      t.string :numero_medidor
      t.string :id_servicio
      t.integer :cod_localidad
      t.integer :lote
      t.string :direccion
      t.string :nombre_cliente
      t.float :diametro
      t.string :marca

      t.timestamps
    end
  end
end
