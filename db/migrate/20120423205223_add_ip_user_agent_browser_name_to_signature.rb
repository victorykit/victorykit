class AddIpUserAgentBrowserNameToSignature < ActiveRecord::Migration
  def change
    add_column :signatures, :ip_address, :string
    add_column :signatures, :user_agent, :string
    add_column :signatures, :browser_name, :string
  end
end
