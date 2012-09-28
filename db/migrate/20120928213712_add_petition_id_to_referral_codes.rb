class AddPetitionIdToReferralCodes < ActiveRecord::Migration
  def change
    add_column :referral_codes, :petition_id, :integer
  end
end
