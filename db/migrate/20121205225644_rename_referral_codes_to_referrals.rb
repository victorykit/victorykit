class RenameReferralCodesToReferrals < ActiveRecord::Migration

  def change
    rename_table :referral_codes, :referrals
  end

end
