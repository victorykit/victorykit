require 'spec_helper'

describe SignaturesController do
  context "signing a petition" do
    it "should let me sign a petition" do
      petition = Petition.create!
      post :create, :petition_id => petition.id, :signature => {:name => "Bob", :email => "bob@thoughtworks.com"}
      petition.signatures[0].name.should eq "Bob"
    end
  end
end
