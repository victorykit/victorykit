require 'smoke_spec_helper.rb'
require 'uri'

include Rails.application.routes.url_helpers

describe 'Petition page' do
  pending "figure out how to forget that a member has signed" do
    let(:petition) {create :petition}

    it 'should allow users to sign' do
      go_to petition_path(petition)
      type('bob').into(:id => 'signature_name')
      type('bob@bobs.com').into(:id => 'signature_email')
      click :id => 'sign_petition'
    
      wait.until { element :class => "thanks" }
    end
  end
end