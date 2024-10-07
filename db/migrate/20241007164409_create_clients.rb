class CreateClients < ActiveRecord::Migration[7.2]
  def change
    remove_column :meters, :service_number, :service_number
    remove_column :meters, :address, :service_number
    remove_column :meters, :client_name, :service_number
    remove_column :meters, :zone_id, :bigint

    create_table :clients do |t|
      t.string :service_number
      t.string :address
      t.string :client_name
      t.string :route
      t.string :phone_number
      t.string :mobile_number
      t.string :email

      t.timestamps
    end

  end
end
