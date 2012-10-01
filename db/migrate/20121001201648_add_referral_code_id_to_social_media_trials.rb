class AddReferralCodeIdToSocialMediaTrials < ActiveRecord::Migration
  def change
    add_column :social_media_trials, :referral_code_id, :integer # Will migrate old referral codes as a one-off in the future.
    add_index :social_media_trials, :referral_code_id
  end
end
