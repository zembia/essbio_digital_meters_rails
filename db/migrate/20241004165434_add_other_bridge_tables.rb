class AddOtherBridgeTables < ActiveRecord::Migration[7.2]
  def change
    #create_table :maestroclientes do |t|
    #  t.string :deveui
    #  t.string :numero_medidor
    #  t.string :id_servicio
    #  t.integer :cod_localidad
    #  t.integer :lote
    #  t.string :direccion
    #  t.string :nombre_cliente
    #  t.float :diametro
    #  t.string :marca
    #end

    #create_table :localidades do |t|
    #  t.integer :cod_localidad
    #  t.string :nombre
    #  t.integer :id_empresa
    #end

    create_table :alertas do |t|
      t.string :deveui
      t.integer :lectura1
      t.string :statemesages
      t.datetime :logdate
      t.date :fecha_logdate
      t.time :hora_logdate
    end 
  end
end
