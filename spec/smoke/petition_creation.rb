require 'uri'

include Rails.application.routes.url_helpers

describe 'Petition create page' do

  before :each do
    login_as_admin
    go_to "petitions/new"
  end

  it 'should allow users to create a petition' do
    type('a snappy title').into(:id => 'petition_title')
    type('a compelling description').into(:id => 'petition_description')
    click :name => 'commit'
  
    wait.until { element :class => "petition" }

    element(:class => "petition_title").text.should == 'a snappy title'
    element(:class => "description").text.should == 'a compelling description'
  end
end