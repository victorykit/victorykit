web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
mailer: rails runner worker/email_scheduler.rb
worker: bundle exec sidekiq -c 20
