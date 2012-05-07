# Be sure to restart your server when you modify this file.
uri = URI.parse(Settings.redis.uri)
Victorykit::Application.config.session_store :redis_store, :servers => uri.to_s

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Victorykit::Application.config.session_store :active_record_store
