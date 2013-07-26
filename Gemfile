source 'https://rubygems.org'

gem 'rack-cache'
gem 'rails', '3.2.12'
gem 'pg'
gem 'foreigner'
gem 'memcachier'
gem 'dalli'
gem 'kgio'

group :production do
  # just used for unsubscribes import
  gem 'mysql'
  gem 'mysql2'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'uglifier', '>= 1.0.3'
  gem 'anjlab-bootstrap-rails', '>= 2.2', :require => 'bootstrap-rails'
  gem 'jquery-datatables-rails', :github => 'rweng/jquery-datatables-rails'
  gem 'jquery-ui-rails'
  gem 'jquery-rails'
end

group :test, :development do
  gem 'rspec'
  gem 'rspec-rails'
  gem 'factory_girl_rails', '~> 3.0'
  gem 'faker', '~> 1.0'
  gem 'autotest'
  gem 'simplecov', :require => false
  gem 'selenium-webdriver'
  gem 'hirb'
  gem 'jslint_on_rails'
  gem 'capybara', '>= 2.0.2'
  gem 'capybara-webkit'
  gem 'debugger'
  gem 'shoulda-matchers'
  gem 'nokogiri'
end

group :development do
  gem 'hitch'
end

gem 'geocoder'

gem 'haml'
gem 'simple_form'
gem 'browser'
gem 'bootstrap-wysihtml5-rails', :github => 'mkurutin/bootstrap-wysihtml5-rails'

gem 'aws-ses', '~> 0.4.4', :require => 'aws/ses'
gem 'aws-sdk'
gem 'garb'
gem 'oauth'
gem 'rails_config'

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby', '~> 3.0.0'

# for whiplash
gem 'redis'
gem 'simple-random'

gem 'newrelic_rpm'
gem 'newrelic-redis'
gem 'airbrake'
gem 'unicorn'

gem 'kaminari'
gem 'redis-store'
gem 'redis-rails'

gem 'dkim'
gem 'sanitize'
gem 'rinku', :require => 'rails_rinku'
gem 'flot-rails'
gem 'truncate_html'
gem 'memoist', :github => 'matthewrudy/memoist'
gem 'premailer'
gem 'whiplash', :github => 'victorykit/whiplash'
gem 'carmen-rails'
gem 'statsd-ruby', :require => 'statsd'
gem 'bumbler'
gem 'fb_graph'
gem 'will_paginate'
gem 'active_attr'

# Background workers
gem 'slim', '>= 1.1.0'
gem 'sinatra', '>= 1.3.0', :require => nil
gem 'sidekiq'
