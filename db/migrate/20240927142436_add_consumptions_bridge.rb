class AddConsumptionsBridge < ActiveRecord::Migration[7.2]
  def change
    create_table :consumptions_per_hour do |t|
      t.string :deveui
      t.datetime :logdate
      t.date :fecha_log
      t.time :hora_log
      t.date :fecha
      t.time :hora
      t.integer :consumo
      t.integer :consumo_acumulado
      t.timestamps
    end
  end
end
