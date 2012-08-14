class AddFacebookFriendsTable < ActiveRecord::Migration
  def change
  	create_table :facebook_friends do |t|
		t.integer :member_id, null: false
		t.string :facebook_id, null: false
		t.timestamps
	end 	
	
	add_index :facebook_friends, [:member_id, :facebook_id], unique: true,  name:  'unique_facebook_friend'  	
	add_foreign_key :facebook_friends, :members, name: "facebook_friends_member_id_fk", column: "member_id"  	
  end
end
