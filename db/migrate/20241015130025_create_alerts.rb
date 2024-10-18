class CreateAlerts < ActiveRecord::Migration[7.2]
  def change
    create_table :alerts do |t|
      t.integer :lectura1
      t.string :statemessages
      t.datetime :logdate
      t.references :meter, null: false, foreign_key: true

      t.timestamps
    end
  end
end
