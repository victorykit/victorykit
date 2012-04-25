class ChangePetitionTitleToText < ActiveRecord::Migration
  def up
    change_column :petitions, :title, :text
  end

  def down
    change_column :petitions, :title, :string
  end
end
