#!/usr/bin/env ruby

def confirm lib_name, required_version
  output = `#{lib_name} --version`.split(' ')
  version = output.length > 1 ? output[1].strip : ""
  if version == required_version
    puts "OK - #{lib_name} #{version}"
    true
  else
    puts "ERR - please install #{lib_name} #{required_version}"
    false
  end
end

confirm "ruby", "1.9.3p125"
confirm "redis-cli", "2.4.11"
confirm "rails", "3.2.3"

if (confirm "psql", "9.1.3")
  if `echo "select 1" | psql -At postgres`.strip == "1"
    puts "OK - postgres 9.1.3 up and running"
  else
    puts "ERR - postgres isn't running"
  end
end
