require 'smoke_spec_helper.rb'
require 'uri'

include Rails.application.routes.url_helpers

describe 'Petition page' do
  before :each do
    go_to petition_path(create_a_petition)
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
