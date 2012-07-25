class CreatePetitionImages < ActiveRecord::Migration
  def change
  	create_table :petition_images do |t|
      t.text :url, null: false
      t.integer :petition_id, null: false
      t.timestamps
    end

    add_foreign_key :petition_images, :petitions, :name => "petition_images_petition_id_fk", :column => "petition_id"
  end
end
