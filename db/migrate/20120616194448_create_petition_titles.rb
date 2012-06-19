class CreatePetitionTitles < ActiveRecord::Migration
  def change
    create_table :petition_titles do |t|
      t.text :title, null: false
      t.string :title_type, null: false
      t.integer :petition_id, null: false
      t.timestamps
    end

    add_foreign_key :petition_titles, :petitions, :name => "petition_titles_petition_id_fk", :column => "petition_id"
  end
end
