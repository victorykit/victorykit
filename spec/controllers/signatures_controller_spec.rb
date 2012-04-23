require 'spec_helper'

describe SignaturesController do
  context "signing a petition" do
    it "should let me sign a petition" do
      petition = Petition.create!
      post :create, :petition => petition, :signature => {:name => "Bob", :email => "bob@thoughtworks.com"}
      
    end
  end
end
