require 'spec_helper'

describe SignaturesController do
  let(:petition){ create(:petition) }
  let(:signature_fields) { {first_name: "Bob", last_name: "Loblaw", email: "bob@my.com"} }
  let(:referring_url) { "http://petitionator.com/456?other_stuff=etc" }

  describe "POST create" do
    context "the user supplies both a name and an email" do
      describe "new signature" do
        subject  do
          sign_petition
          petition.signatures[0]
        end
        its(:first_name) { should == signature_fields[:first_name] }
        its(:last_name) { should == signature_fields[:last_name] }
        its(:email) { should == signature_fields[:email] }
        its(:ip_address) { should == "0.0.0.0" }
        its(:user_agent) { should == "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_4) AppleWebKit/536.11 (KHTML, like Gecko) Chrome/20.0.1132.57 Safari/536.11" }
        its(:browser_name) { should == "chrome" }
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

      it "should record hashed member id to cookies" do
        sign_petition
        cookies[:member_id].should == Signature.find_by_email(signature_fields[:email]).member.to_hash
      end

      it "should redirect to the petition page" do
        sign_petition
        hash = Signature.last.member.to_hash
        should redirect_to petition_url(petition, l: hash)
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
        Member.exists?(email: signature_fields[:email]).should be_true
      end
      it "should indicate that this was the first petition signed by this member" do
        signature = Signature.find_by_email signature_fields[:email]
        signature.created_member.should be_true
      end
    end
    context "the user signed from an emailed link" do
      let(:email) { create :sent_email }

      it "should record wins for any email experiments" do
        EmailExperiments.any_instance.should_receive(:win!)
        sign_petition email_hash: email.to_hash
      end

      it "should update sent email record with the signature_id value" do
        sign_petition email_hash: email.to_hash
        SentEmail.last.signature_id.should == Signature.last.id
      end

      it "should set referer and reference type for the signature" do
        member = create :member, first_name: signature_fields[:first_name], last_name: signature_fields[:last_name],email: signature_fields[:email]
        email.member = member
        email.save!
        sign_petition email_hash: email.to_hash
        Signature.last.reference_type.should == Signature::ReferenceType::EMAIL
        Signature.last.referring_url.should be_nil
        Signature.last.referer.should == member
      end
    end

    context "the user signed from a facebook like post" do
      let(:member) { create :member}
      let(:fb_like_hash) { member.to_hash }

      it "should set referer and reference type for the signature" do
        sign_petition fb_like_hash: fb_like_hash
        Signature.last.reference_type.should == Signature::ReferenceType::FACEBOOK_LIKE
        Signature.last.referring_url.should == referring_url
        Signature.last.referer.should == member
      end

      it "should declare win on facebook_like option" do
        controller.stub(:win_on_option!)
        controller.should_receive(:win_on_option!).with("facebook sharing options", "facebook_like")
        sign_petition fb_like_hash: fb_like_hash
      end
    end

    context "the user signed from a facebook shared link" do
      let(:member) { create :member}
      let(:fb_share_link_ref) { member.to_hash }

      it "should set referer and reference type for the signature" do
        sign_petition fb_share_link_ref: fb_share_link_ref
        Signature.last.reference_type.should == Signature::ReferenceType::FACEBOOK_POPUP
        Signature.last.referring_url.should == referring_url
        Signature.last.referer.should == member
      end

      it "should declare win on facebook_popup option" do
        controller.stub(:win_on_option!)
        controller.should_receive(:win_on_option!).with("facebook sharing options", "facebook_popup")
        sign_petition fb_share_link_ref: fb_share_link_ref
      end
    end

     context "the user signed from a facebook posted action" do
      let(:member) { create :member}
      let(:fb_action) { create :share, :member => member, :action_id => "abcd1234" }

      it "should set referer and reference type for the signature" do
        sign_petition fb_action_id: fb_action.action_id
        Signature.last.reference_type.should == Signature::ReferenceType::FACEBOOK_SHARE
        Signature.last.referring_url.should == referring_url
        Signature.last.referer.should == member
      end

      it "should declare win on facebook_share option" do
        controller.stub(:win_on_option!)
        controller.should_receive(:win_on_option!).with("facebook sharing options", "facebook_share")
        sign_petition fb_action_id: fb_action.action_id
      end
    end

    context "the user signed from a forwarded notification" do
      let(:member) { create :member}
      let(:forwarded_notification_hash) { member.to_hash }

      it "should set referer and reference type for the signature" do
        sign_petition forwarded_notification_hash: forwarded_notification_hash
        Signature.last.reference_type.should == Signature::ReferenceType::FORWARDED_NOTIFICATION
        Signature.last.referring_url.should == referring_url
        Signature.last.referer.should == member
      end
    end

    context "the user signed from a shared link" do
      let(:member) { create :member}
      let(:shared_link_hash) { member.to_hash }

      it "should set referer and reference type for the signature" do
        sign_petition shared_link_hash: shared_link_hash
        Signature.last.reference_type.should == Signature::ReferenceType::SHARED_LINK
        Signature.last.referring_url.should == referring_url
        Signature.last.referer.should == member
      end
    end

    context "the user signed from a tweeted link" do
      let(:member) { create :member}
      let(:twitter_hash) { member.to_hash }

      it "should set referer and reference type for the signature" do
        sign_petition twitter_hash: twitter_hash
        Signature.last.referring_url.should == referring_url
        Signature.last.reference_type.should == Signature::ReferenceType::TWITTER
        Signature.last.referer.should == member
      end
    end

    context "the user signed from a facebook dialog request link" do
      let(:member) { create :member}
      let(:fb_dialog_request) { member.to_hash }

      it "should set referer and reference type for the signature" do
        sign_petition fb_dialog_request: fb_dialog_request
        Signature.last.referring_url.should == referring_url
        Signature.last.reference_type.should == Signature::ReferenceType::FACEBOOK_REQUEST
        Signature.last.referer.should == member
      end
    end
    
    def sign_petition params = {}
      request.env["HTTP_USER_AGENT"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_4) AppleWebKit/536.11 (KHTML, like Gecko) Chrome/20.0.1132.57 Safari/536.11"
      post :create, params.merge({petition_id: petition.id, signature: signature_fields, referring_url: referring_url})
    end
    
    def sign_without_name_or_email
      post :create, petition_id: petition.id
    end
  end
end