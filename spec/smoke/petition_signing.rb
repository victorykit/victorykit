require 'smoke_spec_helper.rb'
require 'uri'

include Rails.application.routes.url_helpers

describe 'Petition page' do
  before :each do
    go_to petition_path(create_a_petition)
    wait.until { element :id => 'signature_email' }
  end
  it 'should allow users to sign' do
    sign_petition
    element(:id => "thanks-for-signing-message").should be_displayed
    element(:class => "signature-form").should_not be_displayed
  end
  it 'should ensure user provides a name' do
    sign_petition '', 'bob@bobs.com'
    element(:class => 'help-inline').text.should == "can't be blank"
  end
end

def sign_petition (name = 'bob loblaw', email = 'bob@bobs.com')
  if element_exists :id => 'signature_first_name'
    first_name, last_name = name.split(' ')
    type(first_name).into(:id => 'signature_first_name')
    type(last_name).into(:id => 'signature_last_name')
  else
    type(name).into(:id => 'signature_name')
  end
  type(email).into(:id => 'signature_email')
  click :id => 'sign_petition'
end
