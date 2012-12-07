class ChangePetitionVersionTitleToText < ActiveRecord::Migration
  def up
    change_column :petition_versions, :title, :text
  end

  def down
    change_column :petition_versions, :title, :string
  end
end
