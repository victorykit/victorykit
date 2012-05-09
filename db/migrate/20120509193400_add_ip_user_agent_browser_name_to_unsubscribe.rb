class AddIpUserAgentBrowserNameToUnsubscribe < ActiveRecord::Migration
  def change
    add_column :unsubscribes, :ip_address, :string
    add_column :unsubscribes, :user_agent, :string
  end
end
