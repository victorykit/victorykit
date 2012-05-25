require "selenium-webdriver"
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

ENV["RAILS_ENV"] ||= 'test'
HOST_URL = "http://localhost:3000"

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.use_transactional_fixtures = true

  config.before(:suite) do
    $driver = Selenium::WebDriver.for :chrome
    create_admin_user
    create_normal_user
  end
  config.after(:suite) do
    $driver.quit unless $driver.nil?
  end
  config.after(:each) do
    log_out
  end
end

def wait_for_ajax
  wait.until {$driver.execute_script "return jQuery.active == 0"}
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

def element_exists locator
  begin
    element locator
  rescue
    false
  end
end

def wait timeout = 20
  Selenium::WebDriver::Wait.new(:timeout => timeout)
end

def login_as_admin
  login "admin@test.com", "password"
end

def login email = "user@test.com", password = "password"
  $driver.navigate.to URI.join(HOST_URL, 'login').to_s
  type(email).into(:id => "new_session_email")
  type(password).into(:id => "new_session_password")
  click(:name => "commit")
end

def log_out
  if(element_exists :link_text => "Log Out")
    element(:link_text => "Log Out").click
  end
end

def go_to resource
  uri = URI.join(HOST_URL, resource).to_s
  $driver.navigate.to(uri)
end

def create_admin_user
  if User.exists? email: "admin@test.com"
    return
  end
  u = User.new({email: "admin@test.com", password: "password", password_confirmation: "password"})
  u.is_admin = true
  raise "failed to create admin user" unless u.save
end
  
def create_normal_user
  if User.exists? email: "user@test.com"
    return
  end
  u = User.new({email: "user@test.com", password: "password", password_confirmation: "password"})
  raise "failed to create user" unless u.save
end

class TextTyper
  def initialize text
    @text = text
  end
  
  def into locator
    input = element(locator)
    input.send_keys @text
  end
end