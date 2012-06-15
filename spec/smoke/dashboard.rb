require 'smoke_spec_helper'
require 'nokogiri'

describe "statistics dashboard" do
	it "shows stats for a petition" do
	  as_admin do
			go_to 'admin/petitions'
		  wait_for_ajax
		  doc = Nokogiri::HTML($driver.page_source)
		  doc.xpath("count(//table/tbody/tr)").should_not be_zero
		end
	end
end