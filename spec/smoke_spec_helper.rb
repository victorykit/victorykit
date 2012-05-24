require "selenium-webdriver"
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

ENV["RAILS_ENV"] ||= 'test'
HOST_URL = "http://localhost:3000"

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

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

def login_as_admin
  login "admin@victorykit.com", "password"
end

def login email, password
  
  $driver.navigate.to URI.join(HOST_URL, 'login').to_s
    
  type(email).into(:id => "new_session_email")
  type(password).into(:id => "new_session_password")
  click(:name => "commit")
end

def log_out
  element(:link_text => "Log Out").click
end

def go_to resource
  uri = URI.join(HOST_URL, resource).to_s
  $driver.navigate.to(uri)
end
  
class TextTyper
  def initialize text
    @text = text
  end
  
  def into locator
    input = $driver.find_element(locator)
    input.send_keys @text
  end
end