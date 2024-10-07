class CreateUserClients < ActiveRecord::Migration[7.2]
  def change
    create_table :user_clients do |t|
      t.belongs_to :user, null: false, foreign_key: true, index: true
      t.belongs_to :client, null: false, foreign_key: true, index: true
      t.string :name

      t.timestamps
    end
  end
end
