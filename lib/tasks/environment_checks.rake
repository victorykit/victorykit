task :check_env do
  confirm_version("ruby", "1.9.3p125")
  confirm_version("redis-cli", "2.4.11")
  confirm_version("rails", "3.2.3")
  confirm_version("psql", "9.1.3")
  confirm_version("bundle", "1.1.3")
end

def confirm_version lib_name, required_version
  if `#{lib_name} --version`.include? required_version
    puts "#{lib_name} #{required_version} OK"
  else
    puts "Warning - you have the wrong version of #{lib_name}. Please install #{required_version}"
  end
end