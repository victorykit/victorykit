require 'selenium/webdriver'
require 'io/console'

puts "RoF user:"
rof_user = gets.chomp
puts "RoF password:"
rof_password = STDIN.noecho(&:gets).chomp
puts "Thanks. Logging in to Rails on Fire..."

begin
  d = Selenium::WebDriver.for :chrome
  d.navigate.to 'http://railsonfire.com'
  login_link = d.find_element(id: 'login')
  login_link.click
  emails = d.find_elements(id: 'user_email')
  emails[1].send_keys rof_user
  passwords = d.find_elements(id:'user_password')
  passwords[1].send_keys rof_password
  sign_in_button = d.find_element(id: 'signin')
  sign_in_button.click
  dashboard_link = d.find_element(link_text: 'Dashboard')
  dashboard_link.click

  Thread.new do
    loop do
      exit if gets.chomp == 'q'
    end
  end

  puts "Monitoring build.  Press 'q <enter>' to quit"

  while true
    latest_build = d.find_element(xpath: "//a[contains(@class, 'build last')]")
    status_class = latest_build.attribute("class").split(" ")[1]
    build_status = status_class.split("-").last
    if(build_status == 'error')
      user_text = latest_build.find_element(class: 'build_user').text
      build_breaker = user_text.split(' ')[0]
      message = "#{build_breaker} broke the build"
      puts message
      `say #{build_breaker} broke the build`
    end
    sleep 60
    d.navigate.refresh
  end
ensure
  d.quit
end