class DeleteNeighborsAndRecreate < ActiveRecord::Migration[7.2]
  def change
    drop_table :meter_neighbors do |t|
      t.references :meter, null: false, foreign_key: { to_table: :meters }, index: true
      t.references :neighbor, null: false, foreign_key: { to_table: :meters }, index: true

      t.timestamps
    end

    create_table :client_neighbors do |t|
      t.references :client, null: false, foreign_key: { to_table: :clients }, index: true
      t.references :neighbor, null: false, foreign_key: { to_table: :clients }, index: true

      t.timestamps
    end
  end
end
