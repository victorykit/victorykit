require 'selenium/webdriver'

class RailsOnFire
  def initialize driver
    @driver = driver
  end

  def log_in
    @driver.navigate.to 'http://railsonfire.com'
    login_link = @driver.find_element(id: 'login')
    login_link.click
    emails = @driver.find_elements(id: 'user_email')
    emails[1].send_keys $rof_user
    passwords = @driver.find_elements(id: 'user_password')
    passwords[1].send_keys $rof_password
    sign_in_button = @driver.find_element(id: 'signin')
    sign_in_button.click
    dashboard_link = @driver.find_element(link_text: 'Dashboard')
    dashboard_link.click
  end

  def current_build
    @driver.navigate.refresh

    latest_build = @driver.find_element(xpath: "//a[contains(@class, 'boxes-success')]")
    latest_build = latest_build.nil? ? @driver.find_element(xpath: "//a[contains(@class, 'boxes-failure')]") : latest_build
    status_class = latest_build.attribute("class").split(" ")[1]
    build_status = status_class.split("-").last
    user_text = latest_build.find_element(class: 'build_user').text
    builder = user_text.split(' ')[0]

    {status: build_status, builder: builder}
  end
end