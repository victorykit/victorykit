require 'smoke_spec_helper.rb'

describe "front page" do
  before :each do
    go_to HOST_URL
  end
  
  it "should not blow up" do
    element(:class => 'title').text.should == 'Win your campaign for change'
  end
  
  it "should ask users to log in before creating a petition" do
    click :class => 'btn-primary'
    wait.until { element :class => "email" }
  end
end