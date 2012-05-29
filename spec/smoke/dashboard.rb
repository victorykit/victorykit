require 'smoke_spec_helper'
require 'nokogiri'

describe "statistics dashboard" do
	before :each do 
	  login_as_admin
	end
	  
	it "shows stats for a petition" do
	  go_to 'admin/petitions'
	  wait_for_ajax
	  doc = Nokogiri::HTML($driver.page_source)

	  go_to 'admin/petitions.json'
	  json = Nokogiri::HTML($driver.page_source)

	  row_count = doc.xpath("count(//table/tbody/tr)")
	  row_count.should > 0
	end
end