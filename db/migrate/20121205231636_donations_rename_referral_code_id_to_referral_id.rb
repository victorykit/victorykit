class DonationsRenameReferralCodeIdToReferralId < ActiveRecord::Migration

  def change
    rename_column :donations, :referral_code_id, :referral_id
  end
  
end
