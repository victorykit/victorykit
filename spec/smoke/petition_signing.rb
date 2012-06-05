require 'smoke_spec_helper.rb'
require 'uri'

include Rails.application.routes.url_helpers

describe 'Petition page' do
  it 'should allow users to sign' do
    petition = create_a_petition
    go_to petition_path(petition)

    yes_please = element :id => 'yes_i_want_to_sign'
    if (yes_please && yes_please.displayed?)
      click :id => 'yes_i_want_to_sign'
      wait.until { element :id => 'signature_name' }
    end

    type('bob').into(:id => 'signature_name')
    type('bob@bobs.com').into(:id => 'signature_email')
    click :id => 'sign_petition'
  
    wait.until { element :class => "thanks" }
  end
end

def create_a_petition
  login_as_admin
  go_to "petitions/new"

  type('a snappy title').into(:id => 'petition_title')
  type('a compelling description').into_wysihtml5(:id => 'petition_description')
  click :name => 'commit'

  wait.until { element :class => "petition" }

  title = element(:class => "petition_title").text
  log_out

  Petition.find_by_title title
end