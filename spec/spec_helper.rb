#require 'simplecov'
#SimpleCov.start

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'rspec/mocks'
require 'capybara/rails'
require 'capybara/rspec'
require 'sidekiq/testing'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  config.include FactoryGirl::Syntax::Methods

  config.before(:each) do
    REDIS.flushdb
    AWS.stub!

    Geocoder.stub(:search).and_return([
      stub.tap do |location|
        location.stub(:city).and_return 'New York'
        location.stub(:metrocode).and_return '1234'
        location.stub(:state).and_return 'New York'
        location.stub(:state_code).and_return 'NY'
        location.stub(:country_code).and_return 'US'
      end
    ])

    $statsd = FakeStatsd.new

    AppSettings.merge(
      "email.from_address"           => "victorykit+sender@example.com",
      "site.name"                    => "example.com",
      "site.email"                   => "victorykit@example.com",
      "site.hostname"                => "example.com",
      "site.feedback_email"          => "victorykit+feedback@example.com",
      "site.list_unsubscribe"        => "victorykit+unsubscribe@example.com",
      "organization.name"            => "VictoryKit",
      "organization.email"           => "victorykit@example.com",
      "organization.unsubscribe_url" => "",
      "organization.logo"            => "logo.png"
    )
  end

  config.after(:each) do
    ActionMailer::Base.deliveries.clear
  end
end

Capybara.default_wait_time = 5
Capybara.register_driver :webkit do |app|
  Capybara::Webkit::Driver.new(app, :stdout => nil)
end

class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil

  def self.connection
    @@shared_connection || retrieve_connection
  end
end

# Forces all threads to share the same connection. This works on
# Capybara because it starts the web server in a thread.
ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection

def valid_session_for user
  sign_in user
  session[:user_id] = @user.id
  nil
end

def valid_session
  @user = create(:user)
  session[:user_id] = @user.id
  sign_in @user
  nil
end

def valid_admin_session
  @user = create(:admin_user)
  session[:user_id] = @user.id
  sign_in @user
  nil
end

def valid_super_user_session
  @user = create(:super_user)
  session[:user_id] = @user.id
  sign_in @user
  nil
end

# redefines a bandit instance to strip out randomness and redis
def stub_bandit bandit

  stub_bandit_spins bandit

  def bandit.win! *args
  end

  def bandit.win_on_option! *args
  end

  def bandit.lose_on_option! *args
  end
end

# redefines spins on a bandit instance to strip out randomness and redis, while preserving
# behavior of wins for cases where the test wants more specific win assertions
def stub_bandit_spins bandit
  def bandit.spin! test_name, goals, options=[true, false], my_session=nil, measure=false
    options.first
  end
end

def stub_bandit_super_spins bandit
  bandit.stub(:super_spin!) do |test_name, goals, options=[true, false], my_session=nil|
    options.first
  end
end

# redefines a bandit class to strip out randomness and redis
def stub_bandit_class bandit_class
  bandit_class.any_instance.stub(:spin!) do |test_name, goals, options=[true, false], my_session=nil|
    options.first
  end
  bandit_class.any_instance.stub(:win!)
  bandit_class.any_instance.stub(:win_on_option!)
end

def guard_against_spins bandit_class
  bandit_class.any_instance.stub(:spin!).and_raise("Should not reach this point. Ensure you have stubbed whatever is calling this.")
end

def wait_until
  require "timeout"
  Timeout.timeout(Capybara.default_wait_time) do
    sleep(0.1) until value = yield
    value
  end
end
