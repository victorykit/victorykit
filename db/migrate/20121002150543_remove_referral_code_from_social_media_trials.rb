class RemoveReferralCodeFromSocialMediaTrials < ActiveRecord::Migration
  def up
    execute <<-SQL
INSERT INTO referral_codes (code, member_id, petition_id)
SELECT referral_code, member_id, petition_id
FROM social_media_trials
GROUP BY referral_code, member_id, petition_id
    SQL
  end

  def down
  end
end
