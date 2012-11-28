class AddAmountToDonationClick < ActiveRecord::Migration
  def change
    add_column :donation_clicks, :amount, :float
  end
end
