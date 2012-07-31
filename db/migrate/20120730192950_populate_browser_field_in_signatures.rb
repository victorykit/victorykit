class PopulateBrowserFieldInSignatures < ActiveRecord::Migration
  def up
    Signature.where("user_agent is not null").each do |signature|
      browser = Browser.new
      browser.ua = signature.user_agent
      signature.browser_name = browser.id.to_s
      signature.save!(:validate => false)
    end
  end

  def down
    Signature.update_all(:browser_name => nil)
  end
end
