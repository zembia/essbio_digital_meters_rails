class CreateNeighbors < ActiveRecord::Migration[7.2]
  def change
    create_table :neighbors do |t|
      t.references :meter, null: false, foreign_key: { to_table: :meters }, index: true
      t.references :neighbor, null: false, foreign_key: { to_table: :meters }, index: true

      t.timestamps
    end
  end
end
