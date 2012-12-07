class AddPetitionVersionTable < ActiveRecord::Migration
  def change
    create_table :petition_versions do |t|
      t.string :title
      t.text :description
      t.integer :petition_id, null: false
      t.timestamps
    end

    add_foreign_key :petition_versions, :petitions, :name => "petition_versions_petition_id_fk", :column => "petition_id"
  end
end
