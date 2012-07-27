class AddFacebookDescriptionToPetitions < ActiveRecord::Migration
  def change
    add_column :petitions, :facebook_description, :text
  end
end
