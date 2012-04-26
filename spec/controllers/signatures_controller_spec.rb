require 'spec_helper'

describe SignaturesController do
  let(:petition){ create(:petition) }
  describe "POST create" do
    context "the user supplies both a name and an email" do
      before(:each) do
        post :create, :petition_id => petition.id, :signature => {:name => "Bob", :email => "bob@my.com"}
      end
      describe "new signature" do
        subject { petition.signatures[0]}
        its(:name) { should == "Bob" }
        its(:email) { should == "bob@my.com" }
        its(:ip_address) { should == "0.0.0.0" }
        its(:user_agent) { should == "Rails Testing" }
      end
      it {should redirect_to petition_url(petition)}
      its(:session) { should include(:signed_petitions => [petition.id]) }
    end
    context "the user leaves a field blank" do
      before :each do
        session[:signed_petitions] = []
        post :create, :petition_id => petition.id
      end
      it "should not add to the signed_petitions in the session" do
        session[:signed_petitions].should_not include(petition.id)
      end
      it "should re-render the petition show page" do
        response.should render_template "petitions/show"
      end
      it "should assign view data required by the petition show page" do
        assigns(:petition).should == petition
      end
    end
  end
end
