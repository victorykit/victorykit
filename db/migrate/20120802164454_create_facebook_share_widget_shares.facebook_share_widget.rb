# This migration comes from facebook_share_widget (originally 20120628021206)
class CreateFacebookShareWidgetShares < ActiveRecord::Migration
  def change
    create_table :facebook_share_widget_shares do |t|
      t.string :user_facebook_id
      t.string :friend_facebook_id
      t.string :url
      t.text :message
      t.timestamps
    end
    
    add_index :facebook_share_widget_shares, [:user_facebook_id, :friend_facebook_id, :url], unique: true,  name:  'unique_share'
  end
end
