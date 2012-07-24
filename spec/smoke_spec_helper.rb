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
  wait_for_ajax
	wait.until { element :id => 'new_session_email' }
	login_here(email, password)
end

def login_here(email = "user@test.com", password = "password")
  type(email).into(:id => "new_session_email")
  type(password).into(:id => "new_session_password")
  click(:id => "login-submit")
end

def log_out
  if element_exists :id => 'logout'
    click(:id => "logout")
  end

end

def force_result(params)
  go_to "whiplash_sessions"
  params.each do |k, v|
    type(v).into(name: k)
  end
  click name: "commit"
end

def set_default_experiment_results
  force_result({
    "signature display threshold" => 0,
    "show thermometer" => 'true',
    "seed signatures with petition creator" => "false"})

    #full (I think) list of experiments that affect layout:
    #
    #"petition side" => "petitionleft",
    #"thermometer and social icon placement" => "therm1",
    #"change button color for sign petition" => "buttoncolor1",
    #"change containing box color for sign petition" => "signaturecolor1",
    #"change thermometer color" => "redthermometer",
    #"change positioning and visibility of labels on sign petition form" => "signature_labels_beside_inputs_no_asterisk",
    #"test different messaging on progress bar" => "x_signatures_of_y",
    #"testing different widths" => "fullwidthpetition",
    #"different background for thank you box" => "hex_f5f5f5",
    #"different arrow colors in thank you box" => "bluearrow",
    #"full name vs first and last name" => "fullname",
    #"facebook sharing options" => "facebook_like",
    #"sign button" => 'Sign!',
    #"signature display threshold" => 0,
    #"show thermometer" => 'true',
    #"seed signatures with petition creator" => "false",
    #"toggle showing vs. not showing modal" => 'false',
    #"change layouts" => "bootstrap",
end

def sign_up(email = Faker::Internet.email, password = "password")
  wait.until { element :id => 'user_email' }
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
  Member.find_by_email email
end

def create_a_petition (title = 'a snappy title', description = 'a compelling description')
  as_user do
    go_to new_petition_path

    wait.until { element :id => 'petition_title' }

    type(title).into(:id => 'petition_title')
    type(description).into_wysihtml5(:id => 'petition_description')
    click :name => 'commit'

    wait.until { element :class => 'petition' }
  end
  Petition.find(:last, order: 'created_at ASC')
end

def create_a_featured_petition (title = 'a featured petition', description = 'these can be emailed', email_subjects = [], facebook_titles = [])
  as_admin do
    go_to new_petition_path

    type(title).into(:id => 'petition_title')
    type(description).into_wysihtml5(:id => 'petition_description')

    if email_subjects and email_subjects.any?
      click :link_text => 'Customize Email Subject'
      email_subjects[1..-1].each do |subject|
        click :link_text => 'Add Email Subject'
      end
    end
    type_into_alt_title_fields "email_subjects", email_subjects

    if facebook_titles and facebook_titles.any?
      click :link_text => 'Customize Facebook Title'
      wait
      facebook_titles[1..-1].each do |title|
        click :link_text => 'Add Facebook Title'
      end
    end
    type_into_alt_title_fields "facebook_titles", facebook_titles

    click :name => 'commit'

    wait.until { element :class => "petition" }
  end
  Petition.find(:last, order: 'created_at ASC')
end

def type_into_alt_title_fields title_type_div_id, alt_titles
  # xpath2 supports regex matching, which would simplify this line, but it doesn't appear to work.
  text_fields = elements(xpath: "//div[@id = '#{title_type_div_id}']//input[@type='text']").select{|x| x.attribute('id').ends_with? 'title'}
  raise "expected #{alt_titles.count} title input fields under #{title_type_div_id} but found #{text_fields.count}" if alt_titles.count != text_fields.count
  text_fields.zip(alt_titles).each {|pair| pair[0].send_keys(pair[1])}
end

def sign_petition (name = 'bob loblaw', email = "bob@yahoo.com")
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

  if element_exists id: 'suggested_email'
    click :id => 'sign_petition'
  end
end

def delete_member_cookie
  $driver.manage.delete_cookie('member_id')
end

def current_member
  cookie = $driver.manage.cookie_named('member_id')
  raise "member_id cookie not found" if not cookie
  member_id = MemberHasher.validate cookie[:value]
  raise "member_id cookie value did not unhash" if not member_id
  Member.find member_id
end
