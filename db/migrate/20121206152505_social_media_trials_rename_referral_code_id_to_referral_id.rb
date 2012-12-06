class SocialMediaTrialsRenameReferralCodeIdToReferralId < ActiveRecord::Migration

  def change
    rename_column :social_media_trials, :referral_code_id, :referral_id
  end

end
