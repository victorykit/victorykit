require 'smoke_spec_helper.rb'
require 'uri'

describe 'Petition create page' do
  it 'should allow users to create a petition' do
    petition = create_a_petition
		go_to petition_path(petition)

    element(:class => "petition_title").text.should == 'a snappy title'
    element(:class => "description").text.should == 'a compelling description'
  end
end