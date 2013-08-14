class AddCreatedAtIndexToFacebookActions < ActiveRecord::Migration
  def change
    add_index :facebook_actions, :created_at
  end
end
