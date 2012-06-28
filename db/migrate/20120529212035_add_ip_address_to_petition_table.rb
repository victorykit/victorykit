class AddIpAddressToPetitionTable < ActiveRecord::Migration
  def change
    add_column :petitions, "ip_address", :string
  end
end
