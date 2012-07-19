require 'smoke_spec_helper.rb'

describe "front page" do
  before :each do
    go_to HOST_URL
  end

  it "should not blow up" do
    element(:class => 'title').text.downcase.should == 'win your campaign for change'
  end

  it "should ask users to log in before creating a petition" do
    click :class => 'btn-primary'
    element(:id => "new_session_email").should be_displayed
    element(:id => "new_session_password").should be_displayed
  end
end
