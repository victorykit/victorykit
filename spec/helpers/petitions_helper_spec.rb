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
    it "creates meta tag for title" do
      petition = Petition.new(title:"whales")
      helper.petition_to_open_graph(petition)['og:title'].should == "whales"
    end
  end
end
