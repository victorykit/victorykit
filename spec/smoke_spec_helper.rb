require "selenium-webdriver"
HOST_URL = "http://localhost:3000"

RSpec.configure do |config|
  config.before(:suite) do
    $driver = Selenium::WebDriver.for :chrome
  end
  config.after(:suite) do
    $driver.quit unless $driver.nil?
  end
end
  
def click locator
  element(locator).click
end

def type text
  TextTyper.new text
end

def element locator
  $driver.find_element(locator)
end

def wait timeout = 5
  Selenium::WebDriver::Wait.new(:timeout => timeout)
end
  
class TextTyper
  def initialize text
    @text = text
  end
  
  def into input_id
    input = $driver.find_element(:id => input_id)
    input.send_keys @text
  end
end