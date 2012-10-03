class MigrateReferralCodeIdToSocialMediaTrials < ActiveRecord::Migration
  def up
    execute <<-SQL
UPDATE social_media_trials
SET referral_code_id = referral_codes.id
FROM referral_codes
WHERE referral_code = referral_codes.code
AND referral_code_id IS NULL
    SQL
  end

  def down
  end
end
