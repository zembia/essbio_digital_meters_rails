class ChangeClientMeters < ActiveRecord::Migration[7.2]
  def change
    remove_reference :client_meters, :user, foreign_key: true, index: true
    add_reference :client_meters, :client, foreign_key: true, index: true
  end
end
