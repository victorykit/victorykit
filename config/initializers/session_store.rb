# Be sure to restart your server when you modify this file.

Victorykit::Application.config.session_store :redis_store, :servers => File.join(Settings.redis.uri,"/0/rails_session"), :expire_after => 2.weeks

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Victorykit::Application.config.session_store :active_record_store
