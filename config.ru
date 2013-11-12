# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

# Load GC auto-tuning. Testing indicates that this eliminates about 20ms from the Ruby layer.
if defined?(Unicorn)
  require 'ng_oob_gc'
  use Unicorn::NgOobGC, 10, {:path_regex_to_always_gc => %r{\A/admin}, :log_level => 2}
end

run Victorykit::Application
