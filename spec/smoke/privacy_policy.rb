require 'smoke_spec_helper.rb'

describe 'Privacy policy page' do
	it 'should have a title' do
		go_to HOST_URL + "/privacy"
		element(:class => "privacy_title").text.should == "Privacy Policy"
	end
end