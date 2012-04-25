class ChangePetitionDescriptionToText < ActiveRecord::Migration
  def up
    change_column :petitions, :description, :text
  end

  def down
    change_column :petitions, :description, :string
  end
end
