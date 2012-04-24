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
    let(:petition) { Petition.create!(title:"whales", description: "Whales are awesome!!!!")}
    subject {helper.petition_to_open_graph(petition)}
    it { should include("og:type" => "cause")}
    it { should include("og:title" => petition.title)}
    it { should include("og:description" => petition.description)}
    it { should include("og:url" => petition_url(petition))}
    it { should include("og:image" => image_path("petition_fb.png"))}
    it { should include("og:site_name" => "Victory Kit")}
  end
end
