class RenameDonationClicksToDonations < ActiveRecord::Migration

  def change
    rename_table :donation_clicks, :donations
  end

end
