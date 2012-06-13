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

      it "it should record the signature data to the session" do
        sign_petition
        session[:signature_name].should == signature_fields[:name]
        session[:signature_email].should == signature_fields[:email]
        session[:last_signature_id].should == Signature.find_by_email(signature_fields[:email]).id
      end

      it "should redirect to the petition page" do
        sign_petition
        should redirect_to petition_url(petition)
      end
    end
    context "an error occurs when sending the confirmation email" do
      it "should notify user of the error" do
        Notifications.any_instance.stub(:signed_petition).and_raise "bang!"
        sign_petition
        flash.now[:notice].should == "bang!"
      end
    end
    context "the user leaves a field blank" do
      before :each do
        sign_without_name_or_email
      end
      it "should not add to the signed_petitions cookie" do
        response.cookies["signed_petitions"].should_not include {petition.id.to_s}
      end
      it "should redirect to the petition show page" do
        should redirect_to petition_url(petition)
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
    context "the user signed from an emailed link" do
      let(:email) { create :sent_email}
      let(:email_hash) { SentEmailHasher.generate(email.id) }

      it "should record wins for any email experiments" do
        a = create :email_experiment, sent_email: email
        b = create :email_experiment, sent_email: email
        
        SignaturesController.any_instance.should_receive(:win_on_option!).once.with("email_scheduler_nps", petition.id.to_s)
        [a, b].each {|e| SignaturesController.any_instance.should_receive(:win_on_option!).once.with(e.key, e.choice)}

        post :create, petition_id: petition.id, signature: signature_fields, email_hash: email_hash
      end

      it "should update sent email record with the signature_id value" do
        post :create, petition_id: petition.id, signature: signature_fields, email_hash: email_hash
        SentEmail.last.signature_id.should == Signature.last.id
      end

      it "should set referer and reference type for the signature" do
        member = create :member, :name => signature_fields[:name], :email => signature_fields[:email]
        email.member = member
        email.save!
        post :create, petition_id: petition.id, signature: signature_fields, email_hash: email_hash
        Signature.last.reference_type.should == "email"
        Signature.last.referer_id.should == member.id
      end
    end

    context "the user signed from a facebook post" do
      let(:member) { create :member, :name => signature_fields[:name], :email => signature_fields[:email]}
      let(:ref_signature) {  create(:signature, :member_id => member.id) }
      let(:fb_hash) { fb_hash = SignatureHasher.generate(ref_signature.id) }

      it "should set referer and reference type for the signature" do
        post :create, petition_id: petition.id, signature: signature_fields, fb_hash: fb_hash
        puts Signature.all.inspect
        Signature.last.reference_type.should == "facebook"
        Signature.last.referer_id.should == member.id
      end
    end
    
    def sign_petition
      post :create, petition_id: petition.id, signature: signature_fields
    end
    
    def sign_without_name_or_email
      post :create, petition_id: petition.id
    end
    
  end
end
