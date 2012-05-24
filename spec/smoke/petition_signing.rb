require 'smoke_spec_helper.rb'
require 'uri'

describe 'Petition page' do
  before :each do
    uri = URI.join(HOST_URL, 'petitions/1').to_s
    $driver.navigate.to(uri)
    puts $driver.page_source
  end
  it 'should allow users to sign' do
    type('bob').into('signature_name')
    type('bob@bobs.com').into('signature_email')
    click :id => 'sign_petition'
  
    wait.until { $driver.find_element(:class => "thanks") }
  end
end