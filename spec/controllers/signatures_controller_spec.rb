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

      it "it should record hashed member id to cookies" do
        sign_petition
        cookies[:member_id].should == MemberHasher.generate(Signature.find_by_email(signature_fields[:email]).member_id)
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
      it "should not add to cookies" do
        response.cookies["member_id"].should be_nil
      end
      it "should redirect to the petition show page" do
        should redirect_to petition_url(petition)
      end
    end
    context "the user has not signed any petitions" do
      before :each do
        sign_petition
      end
      it "should create a member record" do
        Member.exists?(:email => signature_fields[:email]).should be_true
      end
      it "should indicate that this was the first petition signed by this member" do
        signature = Signature.find_by_email signature_fields[:email]
        signature.created_member.should be_true
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
        Signature.last.referer.should == member
      end
    end

    context "the user signed from a facebook post" do
      let(:member) { create :member, :name => "recomender", :email => "recomender@recomend.com"}
      let(:fb_hash) { fb_hash = MemberHasher.generate(member.id) }

      it "should set referer and reference type for the signature" do
        post :create, petition_id: petition.id, signature: signature_fields, fb_hash: fb_hash
        Signature.last.reference_type.should == "facebook_like"
        Signature.last.referer.should == member
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
