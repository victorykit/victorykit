class CreateReferralCodesTable < ActiveRecord::Migration
  def change
    create_table :referral_codes do |t|
      t.string  :code
      t.integer :member_id
    end

    add_index :referral_codes, :code
    add_index :referral_codes, :member_id
  end
end
