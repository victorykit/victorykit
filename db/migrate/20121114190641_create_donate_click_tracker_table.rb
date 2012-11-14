class CreateDonateClickTrackerTable < ActiveRecord::Migration
  def change
    create_table :donation_clicks do |t|
      t.integer :petition_id
      t.integer :member_id
      t.integer :referral_code_id
      t.timestamps
    end
  end
end
