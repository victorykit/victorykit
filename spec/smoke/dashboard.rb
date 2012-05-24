require 'smoke_spec_helper'
require 'nokogiri'

describe "statistics dashboard" do
  pending "get environment variables into railsonfire" do
    before :each do    
	  login "admin@victorykit.com", "password"
	    
	  $driver.navigate.to URI.join(HOST_URL, 'admin/petitions').to_s
	end
	  
	it "shows stats for a petition" do
	  doc = Nokogiri::HTML($driver.page_source)
	  row_count = doc.xpath("count(//table/tbody/tr)")
	  row_count.should > 0
	end
  end
end