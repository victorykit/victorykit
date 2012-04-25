class PetitionRenameUserIdToOwnerId < ActiveRecord::Migration
  def up
    rename_column :petitions, :user_id, :owner_id
  end

  def down
  end
end
