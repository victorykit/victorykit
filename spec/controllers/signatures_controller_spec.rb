require 'spec_helper'

describe SignaturesController do

  before(:each) do
    stub_bandit controller
  end

  let(:petition) { create(:petition) }
  let(:signature_fields) { {first_name: 'Bob', last_name: 'Loblaw', email: 'bob@my.com'} }
  let(:referring_url) { 'http://petitionator.com/456?other_stuff=etc' }

  describe 'POST create' do
    before do
      Resque.stub(:enqueue)
    end

    context 'when the user supplies both a name and an email' do
      before do 
        ActionMailer::Base.deliveries = []
        sign_petition
      end

      after do 
        member = Signature.last.member
        member.signatures.each &:destroy
        member.destroy
      end
      
      subject { petition.signatures.first }
    
      context 'new signature' do
        its(:first_name) { should == signature_fields[:first_name] }
        its(:last_name) { should == signature_fields[:last_name] }
        its(:email) { should == signature_fields[:email] }
        its(:ip_address) { should == '0.0.0.0' }
        its(:user_agent) { should == 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_4) AppleWebKit/536.11 (KHTML, like Gecko) Chrome/20.0.1132.57 Safari/536.11' }
        its(:browser_name) { should == 'chrome' }
      end

      it 'should record hashed member id to cookies' do
        cookies[:member_id].should == Signature.find_by_email(signature_fields[:email]).member.to_hash
      end

      it 'should redirect to the petition page' do
        hash = Signature.last.member.to_hash
        should redirect_to petition_url(petition, l: hash)
      end

      it 'should create a member record' do
        Member.should exist(:email => signature_fields[:email])
      end

      it 'should indicate that this was the first petition signed by this member' do
        signature = Signature.find_by_email signature_fields[:email]
        signature.created_member.should be_true
      end
    end

    context 'when the user comes from' do
      let(:member) { create(:member, first_name: 'recomender', last_name: 'smith', email: 'recomender@recomend.com') }

      shared_examples 'the event is tracked' do
        before { sign_petition params }
        subject { Signature.last }
        its(:reference_type) { should == type }
        its(:referring_url) { should == referring_url }
        its(:referer) { should == member }
      end

      context 'facebook' do
        shared_examples 'the option wins' do
          specify do
            controller.stub(:win_on_option!)
            controller.should_receive(:win_on_option!).
            with('facebook sharing options', option)
            sign_petition params
          end
        end

        context 'like post' do
          let(:params) { { fb_like_hash: member.to_hash } }
          let(:type) { Signature::ReferenceType::FACEBOOK_LIKE }
          let(:option) { 'facebook_like' }

          it_behaves_like 'the event is tracked'
          it_behaves_like 'the option wins'
        end

        context 'shared link' do
          let(:params) { { fb_share_link_ref: member.to_hash } }
          let(:type) { Signature::ReferenceType::FACEBOOK_POPUP }
          let(:option) { 'facebook_popup' }

          it_behaves_like 'the event is tracked'
          it_behaves_like 'the option wins'
        end

        context 'dialog request link' do
          let(:params) { { fb_dialog_request: member.to_hash } }
          let(:type) { Signature::ReferenceType::FACEBOOK_REQUEST }

          it_behaves_like 'the event is tracked'
        end

        context 'posted action' do
          let(:fb_action) { create :share, :member => member, :action_id => 'abcd1234' }
          let(:params) { { fb_action_id: fb_action.action_id } }
          let(:type) { Signature::ReferenceType::FACEBOOK_SHARE }
          let(:option) { 'facebook_share' }

          it_behaves_like 'the event is tracked'
          it_behaves_like 'the option wins'
        end

        context 'wall widget' do
          let(:params) { { fb_wall_hash: member.to_hash } }
          let(:type) { Signature::ReferenceType::FACEBOOK_WALL }
          let(:option) { 'facebook_wall' }

          it_behaves_like 'the event is tracked'
          it_behaves_like 'the option wins'
        end
      end

      context 'a forwarded notification' do
        let(:params) { { forwarded_notification_hash: member.to_hash } }
        let(:type) { Signature::ReferenceType::FORWARDED_NOTIFICATION }

        it_behaves_like 'the event is tracked'
      end

      context 'a shared link' do
        let(:params) { { shared_link_hash: member.to_hash } }
        let(:type) { Signature::ReferenceType::SHARED_LINK }

        it_behaves_like 'the event is tracked'
      end

      context 'a tweeted link' do
        let(:params) { { twitter_hash: member.to_hash } } 
        let(:type) { Signature::ReferenceType::TWITTER }

        it_behaves_like 'the event is tracked'
      end

      context 'an emailed link' do
        let(:email) { create :sent_email }
        let(:params) { { email_hash: email.to_hash } }
        let(:type) { Signature::ReferenceType::EMAIL }

        it 'should record win for email experiments' do
          EmailExperiments.any_instance.should_receive(:win!)
          sign_petition params
        end

        it 'should update sent email record with the signature_id value' do
          sign_petition params
          SentEmail.last.signature_id.should == Signature.last.id
        end

        context 'referer and reference type for the signature are persisted' do
          before do 
            email.member = member
            email.save!
            sign_petition params
          end

          subject { Signature.last }
          
          its(:reference_type) { should == type }
          its(:referring_url) { should be_nil }
          its(:referer) { should == member }
        end
      end
    end


    context 'when the user leaves a field blank' do
      before { sign_without_name_or_email }

      it { should redirect_to petition_url(petition) }

      it 'should not add to cookies' do
        response.cookies['member_id'].should be_nil
      end
    end

    context 'queuing background processes' do
      subject { petition.signatures.first }

      it "should send a confirmation email after signing" do
        Resque.should_receive(:enqueue).with(SignedPetitionEmailJob, anything)
        sign_petition
      end

      it "should fall back to direct email sending if Resque fails" do
        #just being paranoid - remove this behaviour when we're happy that Resque is working well
        Resque.should_receive(:enqueue).and_raise("bang!")
        Notifications.should_receive(:signed_petition).with(an_instance_of(Signature))
        sign_petition
      end
    end

    context 'when an error occurs while saving the signature' do
      before do
        Signature.any_instance.stub(:save).and_raise 'bang!'
        sign_petition
      end

      it 'should notify user of the error' do
        flash.now[:notice].should == 'bang!'
      end
    end

    def sign_petition params = {}
      request.env['HTTP_USER_AGENT'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_4) AppleWebKit/536.11 (KHTML, like Gecko) Chrome/20.0.1132.57 Safari/536.11'
      post :create, params.merge({petition_id: petition.id, signature: signature_fields, referring_url: referring_url})
    end
    
    def sign_without_name_or_email
      post :create, petition_id: petition.id
    end
  end
end
