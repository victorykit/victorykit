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

def as_admin
	login_as_admin
		yield
	log_out
end

def as_user
	login
		yield
	log_out
end

def login_as_admin
  login "admin@test.com", "password"
end

def login(email = "user@test.com", password = "password")
	go_to 'login'
	login_here(email, password)
end

def login_here(email = "user@test.com", password = "password")
	type(email).into(:id => "new_session_email")
	type(password).into(:id => "new_session_password")
	click(:name => "commit")
end

def log_out
  if(element_exists :link_text => "Log Out")
    element(:link_text => "Log Out").click
  end
end

def sign_up(email = Faker::Internet.email, password = "password")
	element(:link_text => "Sign up!").click
	type(email).into(:id => 'user_email')
	type(password).into(:id => 'user_password')
	type(password).into(:id => 'user_password_confirmation')
	click(:id => 'sign-up-submit')
end

def go_to resource
  uri = URI.join(HOST_URL, resource).to_s
  $driver.navigate.to(uri)
end

def current_path
	URI.split($driver.current_url)[5]
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

def create_a_petition (title = 'a snappy title', description = 'a compelling description')
	as_user do
		go_to new_petition_path

		type(title).into(:id => 'petition_title')
		type(description).into_wysihtml5(:id => 'petition_description')
		click :name => 'commit'

		wait.until { element :class => "petition" }
	end
	Petition.find_by_title title
end

class TextTyper
  def initialize text
    @text = text
  end
  
  def into locator
    input = element(locator)
    input.send_keys @text
  end

  def into_wysihtml5(locator)
    raise "only id locators are supported right now" if(!locator[:id])
    $driver.execute_script("$('##{locator[:id]}').data('wysihtml5').editor.composer.setValue('#{@text}');")
  end
end