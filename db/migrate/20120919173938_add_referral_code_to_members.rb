class AddReferralCodeToMembers < ActiveRecord::Migration
  def up
    add_column :members, :referral_code, :string
    add_index :members, :referral_code
    add_column :social_media_trials, :referral_code, :string
    add_index :social_media_trials, :referral_code
    # In a future migration: remove_column :social_media_trials, :member_id
  end

  def down
    remove_column :members, :referral_code
    remove_index :members, :referral_code
    remove_column :social_media_trials, :referral_code
    remove_index :social_media_trials, :referral_code
  end
end
