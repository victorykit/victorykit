web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
mailer: rails runner worker/email_scheduler.rb
resque: bundle exec rake environment resque:work QUEUE=* VERBOSE=1
