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
  visit test_user["login_url"]
  visit test_user["login_url"]

  # ...or you can do it this way (kept as backup in case of failure of the other),
  # which also works but is a bit slower:
  # visit "http://www.facebook.com"
  # element(id: "email")
  # type(test_user["email"]).into(id: "email")
  # type(test_user["password"]).into(id: "pass")
  # click(id: "loginbutton")
end

def visit_facebook path=nil  
  visit "http://www.facebook.com#{path}"
end

def share_petition fb_test_user, share_mode
  wait_until {find(:id, 'the-one-in-the-modal')}.click
  if (share_mode == :share)
    switch_to_popup do
      wait_until {find(:id, "FB_HiddenContainer")}
      click_button ('Share Link')
    end
  elsif (share_mode) == :request
    within_frame 3 do
      # 'find("checkbox")' doesn't seem to work as expected within frames
      friend_checkbox = wait_until { all("input").select { |e| e["class"] == "checkbox" } .first }
      friend_checkbox.set true
      send_requests_button = all("input").select { |e| e["name"] == "ok_clicked"} .first
      send_requests_button.click
    end
  else
    raise "FB sharing mode #{share_mode} not yet supported in smoke specs. Heave away."
  end
end

def visit_petition_experiments admin
  login(admin.email, admin.password) do
    visit '/admin/experiments?f=petitions'
      yield
  end
end

def click_shared_link expected_link_match
  actual_link = find_link("a link")
  actual_link[:href].should match CGI.escape(expected_link_match)
  actual_link.click
  switch_to_popup do
    yield
  end
end

def click_request_link
  actual_link = find_link("a request")
  CGI.escape(actual_link[:href]).should match CGI.escape("http://apps.facebook.com/victorykit_dev/?fb_source=notification&request_ids=")
  actual_link.click
end

def switch_to_popup
  page.driver.browser.switch_to.window page.driver.browser.window_handles.last do
    yield
  end
end

def current_member
  #note: selenium only
  cookie = page.driver.browser.manage.cookie_named('member_id')
  raise "member_id cookie not found" if not cookie
  Member.find_by_hash(cookie[:value]) or raise "member_id cookie value did not unhash"
end

# clears member cookie
def click_sign_again
  wait_until { find(:id, 'sign-again') }.click
end

def assert_petition_experiment_results experiment_name, spins, wins
  experiment = find_experiment_results experiment_name
  experiment.spins.should eq spins
  experiment.wins.should eq wins
end

def find_experiment_results experiment_name
  table = find(:xpath, "//table[@id = '#{experiment_name}']")
  spins = table.find(:xpath, "tbody/tr/td[@class='spins']").text.to_i
  wins = table.find(:xpath, "tbody/tr/td[@class='wins']").text.to_i
  return OpenStruct.new(spins: spins, wins: wins)
end

def dump_frames indices, locator
  indices.each {|n| dump_frame(n, locator)}
end

def dump_frame n, locator
  within_frame n do
    puts "#{n} *******************"
    all(locator).each { |element| puts "#{element['id']} #{element['class']}" }
  end
end