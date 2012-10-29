class AddTimestampsToReferralCode < ActiveRecord::Migration
  def change
    change_table(:referral_codes) { |t| t.timestamps }
  end
end
