class MakePetitionToSendDefaultValue < ActiveRecord::Migration
  def change
    change_table :petitions do | t |
      t.change :to_send, :boolean, :default => false
    end
  end
end
