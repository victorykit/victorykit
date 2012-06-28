require "selenium-webdriver"
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require "support/webdriver_helpers"
include Rails.application.routes.url_helpers
include WebDriverHelpers

ENV["RAILS_ENV"] ||= 'test'
HOST_URL = "http://localhost:3000"

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.use_transactional_fixtures = true

  config.before(:suite) do
		#this seems to be the only Chromedriver resize method that works on both OSX locally, and in RailsOnFire
	  profile = Selenium::WebDriver::Chrome::Profile.new
	  profile['browser.window_placement.top'] = 0
	  profile['browser.window_placement.left'] = 0
	  profile['browser.window_placement.right'] = 1024
	  profile['browser.window_placement.bottom'] = 768
    $driver = Selenium::WebDriver.for :chrome, profile: profile

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
	wait.until { element :id => 'new_session_email' }
	login_here(email, password)
end

def login_here(email = "user@test.com", password = "password")
	type(email).into(:id => "new_session_email")
	type(password).into(:id => "new_session_password")
	click(:id => "login-submit")
end

def log_out
  if(element_exists :link_text => "Log Out")
    element(:link_text => "Log Out").click
  end
end

def sign_up(email = Faker::Internet.email, password = "password")
	type(email).into(:id => 'user_email')
	type(password).into(:id => 'user_password')
	type(password).into(:id => 'user_password_confirmation')
	click(:id => 'sign-up-submit')
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

def create_member name = 'A Member', email = 'amember@some.com'
	go_to 'subscribe'
	type(name).into(id: 'member_name')
	type(email).into(id: 'member_email')
	click id: 'sign-up-submit'
	Member.last
end

def create_a_petition (title = 'a snappy title', description = 'a compelling description')
	as_user do
		go_to new_petition_path

		type(title).into(:id => 'petition_title')
		type(description).into_wysihtml5(:id => 'petition_description')
		click :name => 'commit'

		wait.until { element :class => "petition" }
	end
	Petition.last
end

def create_a_featured_petition (title = 'a featured petition', description = 'these can be emailed', email_subjects = [])
  as_admin do
    go_to new_petition_path

    type(title).into(:id => 'petition_title')
    type(description).into_wysihtml5(:id => 'petition_description')

    #Could be better...
    email_subjects.each do |subject|
      click :link_text => 'Add Email Subject'
    end
    subject_fields = $driver.find_elements xpath: "//input[contains(@id, 'petition_petition_titles_attributes') and @type = 'text']"
    subject_fields.zip(email_subjects).each {|pair| pair[0].send_keys(pair[1])}

    click :name => 'commit'

    wait.until { element :class => "petition" }
  end
  Petition.last
end

def sign_petition (name = 'bob loblaw', email = 'bob@bobs.com')
	wait.until { element :id => 'signature_email' }

  if element_exists :id => 'signature_first_name'
    first_name, last_name = name.split(' ')
    type(first_name).into(:id => 'signature_first_name')
    type(last_name).into(:id => 'signature_last_name')
  else
    type(name).into(:id => 'signature_name')
  end
  type(email).into(:id => 'signature_email')
  click :id => 'sign_petition'
end