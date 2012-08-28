def create_facebook_test_user user_name="victor", installed=false, login=true
  access_token = fetch_facebook_access_token
  uri = 
    "https://graph.facebook.com/#{facebook_app_id}/accounts/test-users?"\
    "installed=#{installed}"\
    "&name=#{user_name}"\
    "&locale=en_US&permissions=read_stream&method=post"\
    "&access_token=#{access_token}"    
  Rails.logger.debug "creating fb test user: #{uri}"
  test_user = JSON.parse(URI.parse(URI.encode(uri)).read)
  Rails.logger.debug "test user: #{test_user}"
  login_at_facebook test_user if login
  test_user
end

def fetch_facebook_access_token
  uri = 
    "https://graph.facebook.com/oauth/access_token"\
    "?client_id=#{facebook_app_id}"\
    "&client_secret=#{facebook_secret}"\
    "&grant_type=client_credentials"
  Rails.logger.debug "fetching fb access token: #{uri}"
  token = URI.parse(uri).read.match(/^access_token=(.*)/)[1]
  Rails.logger.debug "access token: #{token}"
  token
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

def go_to_facebook
  go_to_external 'http://www.facebook.com'
end

def share_petition_on_facebook fb_test_user, share_mode
  if (share_mode == :share)
    click(:id => 'the-one-in-the-modal')
    $driver.switch_to.window $driver.window_handles.last
    click(:name => 'share')
    $driver.switch_to.window $driver.window_handles.first
  else
    raise "FB sharing mode #{share_mode} not yet supported in smoke specs. Heave away."
  end
end

def facebook_experiment_results_for petition
  as_admin do
    go_to 'admin/experiments?f=petitions'
    table = element(xpath: "//table[@id = 'petition #{petition.id} facebook title']")
    spins = table.find_element(xpath: "tbody/tr/td[@class='spins']").text.to_i
    wins = table.find_element(xpath: "tbody/tr/td[@class='wins']").text.to_i
    return OpenStruct.new(spins: spins, wins: wins)
  end
end

def click_shared_link expected_shared_link
  actual_shared_link = element(link: "a link").attribute "href"
  Rails.logger.debug "actual shared link: #{actual_shared_link}"
  actual_shared_link.match(CGI.escape(expected_shared_link)).should_not be_nil
  go_to expected_shared_link
end

def expected_facebook_share_link petition, member
  "#{petition_path(petition)}?share_ref=#{member.to_hash}"
end