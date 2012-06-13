require 'smoke_spec_helper.rb'
require 'uri'

include Rails.application.routes.url_helpers

describe 'Petition page' do
  it 'should allow users to sign' do
    petition = create_a_petition
    go_to petition_path(petition)

    wait.until { element :id => 'signature_email' }

    sign_petition

    wait.until { element :class => "thanks" }
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
