require 'spec_helper'

describe SignaturesController do
  context "signing a petition" do
    it "should let me sign a petition" do
      petition = Petition.create!
      post :create, :petition_id => petition.id, :signature => {:name => "Bob", :email => "bob@my.com"}
      petition.signatures[0].name.should eq "Bob"
      petition.signatures[0].email.should eq "bob@my.com"
    end
  end
end
