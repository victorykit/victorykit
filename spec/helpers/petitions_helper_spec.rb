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
    let(:config) { { facebook: { site_name: "My Super Petitions", app_id: "12345", image: "foo.com/123.png" } } }
    before(:each) do
      helper.stub(:social_media_config).and_return config
    end    
    subject {
      helper.petition_to_open_graph(petition)}
    it { should include("og:type" => "cause")}
    it { should include("og:title" => petition.title)}
    it { should include("og:description" => strip_tags_except_links(petition.description))}
    it { should include("og:url" => petition_url(petition))}
    it { should include("og:image" => "foo.com/123.png")}
    it { should include("og:site_name" => "My Super Petitions")}
    it { should include("fb:app_id" => "12345")}
  end
end
