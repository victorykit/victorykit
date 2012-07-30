class PopulateBrowserFieldInSignatures < ActiveRecord::Migration
  def up
    Signature.where("user_agent is not null").each do |signature|
      browser = Browser.new
      browser.ua = signature.user_agent
      signature.update_attributes(:browser_name => browser.id.to_s)
    end
  end

  def down
    Signature.update_all(:browser_name => nil)
  end
end
