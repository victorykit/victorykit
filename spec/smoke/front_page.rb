require 'smoke_spec_helper.rb'

describe "front page" do
  before :each do
    $driver.navigate.to HOST_URL
  end
  
  it "should not blow up" do
    welcome = $driver.find_element(:class =>'title')
    welcome.text.should == 'Win your campaign for change'
  end
  
  it "should ask users to log in before creating a petition" do
    link = $driver.find_element(:class => 'btn-primary')
    link.click
    wait = Selenium::WebDriver::Wait.new(:timeout => 5)
    wait.until { $driver.find_element(:class => "email") }
  end
end