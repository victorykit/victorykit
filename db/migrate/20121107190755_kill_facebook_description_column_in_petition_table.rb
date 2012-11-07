class KillFacebookDescriptionColumnInPetitionTable < ActiveRecord::Migration
  def up
    remove_column :petitions, :facebook_description
  end
end
