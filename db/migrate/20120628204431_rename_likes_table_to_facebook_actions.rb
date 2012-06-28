class RenameLikesTableToFacebookActions < ActiveRecord::Migration
  def up
    rename_table :likes, :facebook_actions
    add_column :facebook_actions, :type, :string
    add_column :facebook_actions, :action_id, :string
    FacebookAction.find(:all).each do |record|
      record.type = "Like"
      record.save!
    end
  end

  def down
    remove_column :facebook_actions, :type
    remove_column :facebook_actions, :action_id
    rename_table :facebook_actions, :likes
  end
end
