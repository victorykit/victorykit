def create_facebook_test_user user_name="victor", login=true
  access_token = fetch_facebook_access_token
  uri = 
    "https://graph.facebook.com/#{facebook_app_id}/accounts/test-users?"\
    "installed=true"\
    "&name=#{user_name}"\
    "&locale=en_US&permissions=read_stream&method=post"\
    "&access_token=#{access_token}"    
  log "creating fb test user: #{uri}"
  test_user = JSON.parse(URI.parse(URI.encode(uri)).read)
  log "test user: #{test_user}"
  login_at_facebook test_user if login
  test_user
end

def log message
  Rails.logger.debug "FB: #{message}"
end

def facebook_friend user_a, user_b
  id_a = user_a["id"]
  id_b = user_b["id"]
  token_a = user_a["access_token"]
  token_b = user_b["access_token"]

  uri = "https://graph.facebook.com/#{id_a}/friends/#{id_b}?method=post&access_token=#{token_a}"
  log "friend request: posting from user #{id_a} to #{id_b}"
  log uri
  result = URI.parse(URI.encode(uri)).read
  log result

  uri = "https://graph.facebook.com/#{id_b}/friends/#{id_a}?method=post&access_token=#{token_b}"
  log "friend request: accepting by user #{id_b} in response to #{id_a}"
  log uri
  result = URI.parse(URI.encode(uri)).read
  log result
end

def delete_fb_test_user test_user
  delete_fb_test_user_by_id test_user["id"]
end

def delete_fb_test_user_by_id id
  uri = "https://graph.facebook.com/#{id}?method=delete&access_token=#{fetch_facebook_access_token}"
  URI.parse(URI.encode(uri)).read
end

def delete_all_fb_test_users
  uri = "https://graph.facebook.com/#{facebook_app_id}/accounts/test-users?access_token=#{fetch_facebook_access_token}"
  while uri
    uri = delete_page_of_fb_test_users uri
  end
end

def delete_page_of_fb_test_users uri
  j = JSON.parse(URI.parse(URI.encode(uri)).read)
  j["data"].each do |data|
     delete_fb_test_user_by_id data["id"]
  end
  j["paging"] ? j["paging"]["next"] : nil
end

def fetch_facebook_access_token
  if not @fb_access_token
    uri =
      "https://graph.facebook.com/oauth/access_token"\
      "?client_id=#{facebook_app_id}"\
      "&client_secret=#{facebook_secret}"\
      "&grant_type=client_credentials"
    log "fetching fb access token: #{uri}"
    @fb_access_token = URI.parse(uri).read.match(/^access_token=(.*)/)[1]
    log "access token: #{@fb_access_token}"
  end
  @fb_access_token
end

def facebook_app_id
  ENV['FACEBOOK_APP_ID'] || raise("Missing FACEBOOK_APP_ID setting in environment variables")
end

def facebook_secret
  ENV['FACEBOOK_SECRET'] || raise("Missing FACEBOOK_SECRET setting in environment variables")
end

def login_at_facebook test_user
  # you can either do it this way, where you call it twice
  # (has to be twice! waiting 1-30 seconds won't do it. no sir. twice is the trick.)...
  go_to_external test_user["login_url"]
  go_to_external test_user["login_url"]

  # ...or you can do it this way (kept as backup in case of failure of the other),
  # which also works but is a bit slower:
  # go_to_external "http://www.facebook.com"
  # element(id: "email")
  # type(test_user["email"]).into(id: "email")
  # type(test_user["password"]).into(id: "pass")
  # click(id: "loginbutton")
end

def go_to_facebook path=nil
  uri = "http://www.facebook.com#{path}"
  go_to_external uri
end

def share_petition_on_facebook fb_test_user, share_mode
  click(:id => 'the-one-in-the-modal')
  if (share_mode == :share)
    #click(id: 'the-one-in-the-modal')
    $driver.switch_to.window $driver.window_handles.last
    click(id: 'grant_required_clicked') if element_exists(id: 'grant_required_clicked')
    click(id: 'grant_clicked') if element_exists(id: 'grant_clicked')
    click(name: 'share')
    $driver.switch_to.window $driver.window_handles.first
  elsif (share_mode) == :request
    switch_to_frame(:class => "FB_UI_Dialog")
    checkbox = wait.until { element(class: "checkbox") }
    checkbox.click
    element(name: "ok_clicked").click
    $driver.switch_to.window $driver.window_handles.first
  else
    raise "FB sharing mode #{share_mode} not yet supported in smoke specs. Heave away."
  end
end

def as_admin_at_petition_experiments
  as_admin do
    go_to 'admin/experiments?f=petitions'
      yield
  end
end

def click_shared_link expected_shared_link_match
  verify_and_click_link "a link", CGI.escape(expected_link_match)
end

def click_request_link
  verify_and_click_link "a request", CGI.escape("http://apps.facebook.com/victorykit_dev/?fb_source=notification&request_ids=")
end

def verify_and_click_link link_text, link_match
  actual_link = element(link: link_text).attribute "href"
  log "found link: #{actual_link}"
  log "verifying link against: #{link_match}"
  CGI.escape(actual_link).match(link_match).should_not be_nil
  go_to actual_link
end

def switch_to_frame locator
  frame_id = $driver.find_element(locator)["id"]
  $driver.switch_to.frame frame_id
end