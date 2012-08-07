require 'rspec/core/rake_task'

namespace :spec do
  desc "Run the smoke tests"
  RSpec::Core::RakeTask.new(:smoke) do |t|
    t.pattern = "spec/smoke/**/*.rb"
    response = `curl --silent -I http://localhost:3000`
    raise "Make sure rails is running locally before running webdriver tests" unless response.match "200 OK"
  end
end