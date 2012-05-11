require "selenium-webdriver"

HOST_URL = "http://localhost:3000"

RSpec.configure do |config|
  config.before(:suite) do
    $driver = Selenium::WebDriver.for :chrome
  end
  config.after(:suite) do
    $driver.quit
  end
end