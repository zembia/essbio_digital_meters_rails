class ModifyColumns < ActiveRecord::Migration[7.2]
  def change
    remove_reference :historic_consumptions, :meter, index: true, foreign_key: true
    remove_reference :data_summaries, :meter, index: true, foreign_key: true
    
    add_reference :historic_consumptions, :client, index: true, foreign_key: true
    add_reference :data_summaries, :client, index: true, foreign_key: true
  end
end
