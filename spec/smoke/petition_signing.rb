require 'smoke_spec_helper.rb'
require 'uri'

include Rails.application.routes.url_helpers

describe 'Petition page' do
  let(:petition) {create :petition}

  before :each do
    uri = URI.join(HOST_URL, petition_path(petition)).to_s
    $driver.navigate.to(uri)
  end

  it 'should allow users to sign' do
    type('bob').into(:id => 'signature_name')
    type('bob@bobs.com').into(:id => 'signature_email')
    click :id => 'sign_petition'
  
    wait.until { $driver.find_element(:class => "thanks") }
  end
end