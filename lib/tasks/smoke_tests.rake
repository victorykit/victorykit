require 'rspec/core/rake_task'

namespace :spec do
  desc "Run the smoke tests"
  RSpec::Core::RakeTask.new(:smoke) do |t|
    t.pattern = "spec/smoke/**/*_spec.rb"
  end
end