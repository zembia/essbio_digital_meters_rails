class RenameStateMesagesInAlertas < ActiveRecord::Migration[7.2]
  def change
    rename_column :alertas, :statemesages, :statemessages
  end
end
