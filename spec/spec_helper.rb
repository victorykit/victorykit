require 'simplecov'
SimpleCov.start

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'rspec/mocks'
require 'capybara/rails'
require 'capybara/rspec'

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
  end
end

Capybara.default_wait_time = 5
Capybara.register_driver :webkit do |app| 
  Capybara::Driver::Webkit.new(app, :stdout => nil) 
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

def valid_session
  user = create(:user)
  valid_session_for user
end

def valid_admin_session
  user = create(:admin_user)
  valid_session_for user
end

def valid_session_for user
  {:user_id => user.id}
end

def valid_super_user_session
  user = create(:super_user)
  valid_session_for user
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
  def bandit.spin! test_name, goals, options=[true, false], my_session=nil
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
