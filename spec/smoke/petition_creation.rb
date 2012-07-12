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
end
