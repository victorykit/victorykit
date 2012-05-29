require 'spec_helper'

describe SignaturesController do
  let(:petition){ create(:petition) }
  let(:signature_fields) { {name: "Bob", email: "bob@my.com"} }

  describe "POST create" do
    context "the user supplies both a name and an email" do
      describe "new signature" do
        subject  do
          sign_petition
          petition.signatures[0]
        end
        its(:name) { should == signature_fields[:name] }
        its(:email) { should == signature_fields[:email] }
        its(:ip_address) { should == "0.0.0.0" }
        its(:user_agent) { should == "Rails Testing" }
      end
      before :each do
        ActionMailer::Base.deliveries = []
      end
      it "should send an email to the signatory" do
        sign_petition
        ActionMailer::Base.deliveries.size.should == 1
        email = ActionMailer::Base.deliveries.last
        email[:to].to_s.should == signature_fields[:email]
        email[:subject].to_s.should match /#{petition.title}/
      end
      it "should redirect to the petition page" do
        sign_petition
        
        should redirect_to petition_url(petition)
      end
    end
    context "the user leaves a field blank" do
      before :each do
        sign_without_name_or_email
      end
      it "should not add to the signed_petitions cookie" do
        response.cookies["signed_petitions"].should_not include {petition.id.to_s}
      end
      it "should re-render the petition show page" do
        response.should render_template "petitions/show"
      end
      it "should assign view data required by the petition show page" do
        assigns(:petition).should == petition
        assigns(:sigcount).should == petition.signatures.count
        assigns(:signature).email.should be_nil
        assigns(:signature).name.should be_nil
      end
    end
    context "the user has not signed any petitions" do
      before :each do
        sign_petition
      end
      it "should create a cookie to store signed petitions" do
        response.cookies["signed_petitions"].should eq petition.id.to_s
      end
      it "should create a member record" do
        Member.exists?(:email => signature_fields[:email]).should be_true
      end
      it "should indicate that this was the first petition signed by this member" do
        signature = Signature.find_by_email signature_fields[:email]
        signature.created_member.should be_true
      end
    end
    context "the user has already signed another petition" do
      before :each do
        request.cookies["signed_petitions"] = "some other id"
        sign_petition
      end
      it "should add the signed petition ID into the cookie" do
         response.cookies["signed_petitions"].split("|").should include(petition.id.to_s)
      end
    end
    
    def sign_petition
      post :create, petition_id: petition.id, :signature => signature_fields
    end
    
    def sign_without_name_or_email
      post :create, petition_id: petition.id
    end
    
  end
end
