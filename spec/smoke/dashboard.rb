require 'smoke_spec_helper'
require 'nokogiri'

describe "statistics dashboard" do
	it "shows stats for a petition" do
	  as_admin do
			go_to 'admin/petitions'
		  wait_for_ajax
		  doc = Nokogiri::HTML($driver.page_source)

		  row_count = doc.xpath("count(//table/tbody/tr)")
		  row_count.should > 0
		end
	end
end