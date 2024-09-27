class AddTables < ActiveRecord::Migration[7.2]
  def change
    create_table :zones do |t|
      t.string :name
      t.decimal :neighbor_mean
      t.decimal :efficient_neighbor
      t.timestamps
    end

    create_table :meters do |t|
      t.string :service_number
      t.string :meter_number
      t.string :deveui
      t.string :address
      t.string :client_name
      t.references :zone, foreign_key: true
      t.timestamps
    end

    create_table :user_meters do |t|
      t.references :user, foreign_key: true
      t.references :meter, foreign_key: true
      t.timestamps
    end

    create_table :data_summaries do |t|
      t.decimal :current_consumption
      t.decimal :current_consumption_clp
      t.decimal :projected_consumption_clp
      t.references :meter, foreign_key: true
      t.timestamps
    end

    create_table :historic_consumptions do |t|
      t.decimal :value
      t.integer :period_index
      t.references :meter, foreign_key: true
      t.timestamps
    end

    create_table :cosumptions do |t|
      t.decimal :value
      t.decimal :accumulated_value
      t.references :meter, foreign_key: true
      t.timestamps
      t.timestamp :measured_at
    end

    create_table :notification_types do |t|
      t.string :name
    end

    create_table :notifications do |t|
      t.references :notification_type, foreign_key: true
      t.string :message
      t.timestamps
      t.timestamp :generated_at
    end

    create_table :user_notifications do |t|
      t.references :notification, foreign_key: true
      t.references :user, foreign_key: true
      t.timestamp :seen_at
      t.timestamps
    end

  end
end
