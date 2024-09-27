class AddDeveuiIndexMeters < ActiveRecord::Migration[7.2]
  def change
    
    add_index :meters, :deveui, unique: true
  end
end
