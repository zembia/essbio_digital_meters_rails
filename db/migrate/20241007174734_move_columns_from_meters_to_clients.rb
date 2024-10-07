class MoveColumnsFromMetersToClients < ActiveRecord::Migration[7.2]
  def change
   remove_reference :meters, :group, index: true, foreign_key:true
   remove_reference :meters, :location, index: true, foreign_key:true
   
   add_reference :clients, :group, index: true, foreign_key:true
   add_reference :clients, :location, index: true, foreign_key:true
  end
end
