class AddPetitionToSendOnColumn < ActiveRecord::Migration
  def change
    add_column :petitions, :to_send, :boolean
  end
end
