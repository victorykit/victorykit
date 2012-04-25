require 'spec_helper'

describe SignaturesController do
  let(:petition){ create(:petition) }
  context "POST create" do
    before(:each) do
      post :create, :petition_id => petition.id, :signature => {:name => "Bob", :email => "bob@my.com"}
    end
    describe "new signature" do
      subject { petition.signatures[0] }

      its(:name) { should == "Bob" }
      its(:email) { should == "bob@my.com" }
      its(:ip_address) { should == "0.0.0.0" }
      its(:user_agent) { should == "Rails Testing" }
    end
    it {should redirect_to petition_url(petition)}
    its(:session) { should include(:signed_petitions => [petition.id]) }
  end
end
