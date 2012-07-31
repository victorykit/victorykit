require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the PetitionsHelper. For example:
#
# describe PetitionsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe PetitionsHelper do
  describe "petition_to_open_graph" do 
    include ApplicationHelper   

    let(:petition) { create(:petition)}
    let(:config) { { facebook: { site_name: "My Super Petitions", app_id: 12345 } } }
    before(:each) do
      helper.stub(:spin!).and_return(nil)
      helper.stub(:social_media_config).and_return config
    end    
    subject {
      helper.petition_to_open_graph(petition)}
    it { should include("og:type" => "watchdognet:petition")}
    it { should include("og:title" => petition.title)}
    it { should include("og:description" => strip_tags(petition.description))}
    it { should include("og:image" => Rails.configuration.social_media[:facebook][:image])}
    it { should include("og:site_name" => "My Super Petitions")}
    it { should include("fb:app_id" => 12345)}
  end

  describe "choose_form_based_on_browser" do
    attr_reader :browser

    it "tells IE users to upgrade their shit" do
      @browser = OpenStruct.new(:ie? => true, :user_agent => "MSIE")
      choose_form_based_on_browser.should == 'ie_form'
    end

    it "tolerates IE with chrome frame" do
      @browser = OpenStruct.new(:ie? => true, :user_agent => "MSIE chromeframe")
      choose_form_based_on_browser.should == 'form'
    end
  end

end
