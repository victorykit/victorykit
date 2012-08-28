require 'smoke_spec_helper.rb'
require 'uri'

describe 'Petition create page' do
  it 'should allow users to create a petition' do
    petition = create_a_petition
    go_to petition_path(petition)
    element(:class => "petition_title").text.downcase.should == petition.title.downcase
    element(:class => "description").text.should == petition.description
    log_out
  end
  it 'should redirect to petition create page after logging in' do
    go_to new_petition_path
    login_here
    current_path.should == new_petition_path
    log_out
  end
  it 'should redirect to petition create page after signing up' do
    go_to new_petition_path
    sign_up
    current_path.should == new_petition_path
    log_out
  end
  it "should email a preview of the petition to the current user's email address" do
    as_admin do
      create_member "admin", "user", "admin@test.com"
      `rm -f ./tmp/mails/admin@test.com`
      go_to new_petition_path
      send_email_preview
      email = `cat ./tmp/mails/admin@test.com`
      email.should_not == ""
    end
  end
  it "should not allow non-admins to see email previews" do
    as_user do
      go_to new_petition_path
      element_exists(id: "email_preview_link").should_not be_true
    end
  end
end

def send_email_preview
  click id: "email_preview_link"
  alert = wait.until {alert_is_present}
  alert.accept
end

def alert_is_present
  begin
    a = $driver.switch_to.alert
    return a
  rescue Exception => e
    return nil
  end
end