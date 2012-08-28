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
  #force_result({"seed signatures with petition creator" => "false"})

    #full (I think) list of experiments that affect layout:
    #
    #"petition side" => "petitionleft",
    #"thermometer and social icon placement" => "therm1",
    #"change containing box color for sign petition" => "signaturecolor1",
    #"change thermometer color" => "redthermometer",
    #"test different messaging on progress bar" => "x_signatures_of_y",
    #"testing different widths" => "fullwidthpetition",
    #"different background for thank you box" => "hex_f5f5f5",
    #"different arrow colors in thank you box" => "bluearrow",
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

def create_member first_name = 'A', last_name = 'Member', email = 'amember@some.com'
  go_to 'subscribe'
  type(first_name).into(id: 'member_first_name')
  type(last_name).into(id: 'member_last_name')
  type(email).into(id: 'member_email')
  click id: 'sign-up-submit'
  Member.find_by_email email
end

def create_a_petition (attributes = {})
  attributes = {title: 'a snappy title', description: 'a compelling description'}.merge(attributes)
  as_user do
    go_to new_petition_path

    wait.until { element :id => 'petition_title' }

    type(attributes[:title]).into(:id => 'petition_title')
    type(attributes[:description]).into_wysihtml5(:id => 'petition_description')

    click :name => 'commit'

    wait.until { element :class => 'petition' }
  end
  Petition.find(:last, order: 'created_at ASC')
end


def create_a_featured_petition (attributes = {})
  attributes = {title: 'a featured petition', description: 'these can be emailed', email_subjects: [], facebook_titles: [], image: nil}.merge(attributes)
  as_admin do
    go_to new_petition_path

    type(attributes[:title]).into(:id => 'petition_title')
    type(attributes[:description]).into_wysihtml5(:id => 'petition_description')

    email_subjects = attributes[:email_subjects]

    if email_subjects and email_subjects.any?
      click :link_text => 'Customize Email Subject'
      email_subjects[1..-1].each do |subject|
        click :link_text => 'Add Email Subject'
      end
    end
    type_into_alt_title_fields "email_subjects", email_subjects

    facebook_titles = attributes[:facebook_titles]

    if facebook_titles and facebook_titles.any?
      click :link_text => 'Customize Facebook Title'
      wait
      facebook_titles[1..-1].each do |title|
        click :link_text => 'Add Facebook Title'
      end
    end
    type_into_alt_title_fields "facebook_titles", facebook_titles

    if attributes[:image]
      click id: 'sharing_image_link'
      type_into_alt_image_field attributes[:image]
    end

    click :name => 'commit'

    wait.until { element :class => "petition" }
  end
  Petition.find(:last, order: 'created_at ASC')
end

def type_into_alt_image_field(image)
  type(image).into(css: 'div#sharing_images.controls div.additional_title input[type="text"]')
end

def type_into_alt_title_fields title_type_div_id, alt_titles
  # xpath2 supports regex matching, which would simplify this line, but it doesn't appear to work.
  text_fields = elements(xpath: "//div[@id = '#{title_type_div_id}']//input[@type='text']").select{|x| x.attribute('id').ends_with? 'title'}
  raise "expected #{alt_titles.count} title input fields under #{title_type_div_id} but found #{text_fields.count}" if alt_titles.count != text_fields.count
  text_fields.zip(alt_titles).each {|pair| pair[0].send_keys(pair[1])}
end

def sign_petition (first_name = 'bob', last_name = 'loblaw', email = "bob@yahoo.com")
  wait.until { element :id => 'signature_email' }

  type(first_name).into(:id => 'signature_first_name')
  type(last_name).into(:id => 'signature_last_name')
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
  Member.find_by_hash(cookie[:value]) or raise "member_id cookie value did not unhash"
end

def create_facebook_test_user user_name="victor", installed=false, login=true
  access_token = fetch_facebook_access_token
  uri = 
    "https://graph.facebook.com/#{facebook_app_id}/accounts/test-users?"\
    "installed=#{installed}"\
    "&name=#{user_name}"\
    "&locale=en_US&permissions=read_stream&method=post"\
    "&access_token=#{access_token}"    
  Rails.logger.debug "creating fb test user: #{uri}"
  test_user = JSON.parse(URI.parse(URI.encode(uri)).read)
  Rails.logger.debug "test user: #{test_user}"
  login_at_facebook test_user if login
  test_user
end

def fetch_facebook_access_token
  uri = 
    "https://graph.facebook.com/oauth/access_token"\
    "?client_id=#{facebook_app_id}"\
    "&client_secret=#{facebook_secret}"\
    "&grant_type=client_credentials"
  Rails.logger.debug "fetching fb access token: #{uri}"
  token = URI.parse(uri).read.match(/^access_token=(.*)/)[1]
  Rails.logger.debug "access token: #{token}"
  token
end

def login_at_facebook test_user
  # you can either do it this way, where you call it twice
  # (has to be twice! waiting 1-30 seconds won't do it. no sir. twice is the trick.)...
  go_to_external test_user["login_url"]
  go_to_external test_user["login_url"]

  # ...or you can do it this way (kept as backup in case of failure of the other),
  # which also works but is a bit slower:
  # go_to_external "http://www.facebook.com"
  # element(id: "email")
  # type(test_user["email"]).into(id: "email")
  # type(test_user["password"]).into(id: "pass")
  # click(id: "loginbutton")
end

def go_to_facebook
  go_to_external 'http://www.facebook.com'
end

def facebook_app_id
  ENV['FACEBOOK_APP_ID'] || raise("Missing FACEBOOK_APP_ID setting in environment variables")
end

def facebook_secret
  ENV['FACEBOOK_SECRET'] || raise("Missing FACEBOOK_SECRET setting in environment variables")
end

def share_petition_on_facebook fb_test_user, share_mode
  if (share_mode == :share)
    click(:id => 'the-one-in-the-modal')
    $driver.switch_to.window $driver.window_handles.last
    click(:name => 'share')
    $driver.switch_to.window $driver.window_handles.first
  else
    raise "FB sharing mode #{share_mode} not yet supported in smoke specs. Heave away."
  end
end

def facebook_experiment_results_for petition
  as_admin do
    go_to 'admin/experiments?f=petitions'
    table = element(xpath: "//table[@id = 'petition #{petition.id} facebook title']")
    spins = table.find_element(xpath: "tbody/tr/td[@class='spins']").text.to_i
    wins = table.find_element(xpath: "tbody/tr/td[@class='wins']").text.to_i
    return OpenStruct.new(spins: spins, wins: wins)
  end
end
