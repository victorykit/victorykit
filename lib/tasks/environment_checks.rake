task :check_ruby_version do
  confirm_version("ruby", "1.9.3p125")
  confirm_version("redis-cli", "2.4.11")
  confirm_version("rails", "3.2.3")
  confirm_version("psql", "9.1.3")
end

def confirm_version lib_name, required_version
  puts "Warning - you have the wrong version of #{lib_name}. Please install #{required_version}" unless `#{lib_name} --version`.include? required_version
end