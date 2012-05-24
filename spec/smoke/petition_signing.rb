require 'smoke_spec_helper.rb'
require 'uri'

include Rails.application.routes.url_helpers

describe 'Petition page' do
  let(:petition) {create :petition}

  before :each do
    #log_out #need this when admin login is fixed
    go_to petition_path(petition)
  end

  it 'should allow users to sign' do
    type('bob').into(:id => 'signature_name')
    type('bob@bobs.com').into(:id => 'signature_email')
    click :id => 'sign_petition'
  
    wait.until { element :class => "thanks" }
  end
end