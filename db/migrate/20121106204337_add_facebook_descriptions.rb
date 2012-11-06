class AddFacebookDescriptions < ActiveRecord::Migration
  def change
    create_table :petition_descriptions do |t|
      t.text :facebook_description, null: false
      t.integer :petition_id, null: false
      t.timestamps
    end

    add_foreign_key :petition_descriptions, :petitions, :name => "petition_descriptions_petition_id_fk", :column => "petition_id"
  end
end
