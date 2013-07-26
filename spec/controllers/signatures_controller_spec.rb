describe SignaturesController do

  before(:each) do
    stub_bandit controller
    now = Time.now
    Time.stub(:now).and_return(now)
  end

  let(:petition) { create(:petition) }
  let(:signature_fields) { {first_name: 'Bob', last_name: 'Loblaw', email: 'bob@my.com'} }
  let(:referring_url) { 'http://watchdog.net/123?ref=bzzt' }
  let(:http_referer) { 'http://petitionator.com/456?other_stuff=etc' }

  describe 'GET index' do
    let(:action) { get :index, petition_id: petition.id }
    it_behaves_like "an admin only resource page"

    context 'with signatures' do
      let(:first_signature)  { create(:signature, petition: petition) }
      let(:second_signature) { create(:signature, petition: petition) }

      before do
        get :index, {petition_id: petition.id, format: :csv}, valid_admin_session
      end

      its('response.headers') { should include('Content-Type' => 'text/csv') }
    end
  end

  describe 'POST create' do
    before do
      SignedPetitionEmailJob.stub(:perform_async)
      request.stub(:referer).and_return http_referer
    end

    context 'when the user supplies both a name and an email' do
      let(:code) { "some_code" }
      subject { petition.signatures.first }

      before do 
        ActionMailer::Base.deliveries = []
        sign_petition signer_ref_code: code
      end

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
        should redirect_to petition_url(petition, l: code)
      end

      context 'new member' do
        it 'should create a member record' do
          Member.should exist(:email => signature_fields[:email])
        end

        it 'should indicate that this was the first petition signed by this member' do
          signature = Signature.find_by_email signature_fields[:email]
          signature.created_member.should be_true
        end
      end

      context 'existing member' do
        it 'should update name' do
          signature_fields[:first_name] = 'Robert'
          signature_fields[:last_name] = 'Smith'
          sign_petition signer_ref_code: code
          Signature.last.member.full_name.should == 'Robert Smith'
        end

        it 'should ignore case for email' do
          signature_fields[:email] = 'BoB@My.coM'
          sign_petition signer_ref_code: code
          Member.should_not exist(:email => 'BoB@My.coM')
          Member.find_by_email('bob@my.com').signatures.should have(2).elements
        end
      end
    end

    context 'when the user comes from' do
      let(:member) { create(:member, first_name: 'recomender', last_name: 'smith', email: 'recomender@recomend.com') }
      let(:type) { nil }
      let(:ref_code) { member.to_hash }
      let(:params) { { referer_ref_type: type, referer_ref_code: ref_code } }

      INVERTED_REF_TYPES = SignatureReferral::ALL_REF_TYPES.inject({}) { |h, (k, v)| h.merge! v => k }

      def param_for(reference_type)
        INVERTED_REF_TYPES[reference_type]
      end

      shared_examples 'the event is tracked' do
        before { create :referral, code: member.to_hash, member: member, petition: petition }
        before { sign_petition params }
        subject { Signature.last }
        its(:reference_type) { should == type }
        its(:referring_url) { should == referring_url }
        its(:http_referer) { should == http_referer }
        its(:referer) { should == member }
      end

      context 'facebook' do
        shared_examples 'the option wins' do
          specify do
            controller.stub(:win_on_option!)
            FacebookSharingOptionsExperiment.any_instance.should_receive(:win!).with(an_instance_of(Signature))
            sign_petition params
          end
        end

        context 'like post' do
          let(:type) { Signature::ReferenceType::FACEBOOK_LIKE }
          let(:option) { 'facebook_like' }

          it_behaves_like 'the event is tracked'
          it_behaves_like 'the option wins'
        end

        context 'shared link' do
          let(:type) { Signature::ReferenceType::FACEBOOK_POPUP }
          let(:option) { 'facebook_popup' }

          it_behaves_like 'the event is tracked'
          it_behaves_like 'the option wins'
        end

        context 'dialog request link' do
          let(:type) { Signature::ReferenceType::FACEBOOK_REQUEST }

          it_behaves_like 'the event is tracked'
        end

        context 'posted action' do
          let(:fb_action) { create :share, :member => member, :action_id => 'abcd1234' }
          let(:ref_code) { fb_action.action_id }
          let(:type) { Signature::ReferenceType::FACEBOOK_SHARE }
          let(:option) { 'facebook_share' }

          it_behaves_like 'the event is tracked'
          it_behaves_like 'the option wins'
        end

        context 'recommendation' do
          let(:type) { Signature::ReferenceType::FACEBOOK_RECOMMENDATION }
          let(:option) { 'facebook_recommendation' }

          it_behaves_like 'the event is tracked'
          it_behaves_like 'the option wins'
        end
      end

      context 'a forwarded notification' do
        let(:type) { Signature::ReferenceType::FORWARDED_NOTIFICATION }

        it_behaves_like 'the event is tracked'
      end

      context 'a shared link' do
        let(:type) { Signature::ReferenceType::SHARED_LINK }

        it_behaves_like 'the event is tracked'
      end

      context 'a tweeted link' do
        let(:type) { Signature::ReferenceType::TWITTER }

        it_behaves_like 'the event is tracked'
      end

      context 'an emailed link' do
        let(:email) { create :scheduled_email }
        let(:ref_code) { email.to_hash }
        let(:type) { Signature::ReferenceType::EMAIL }

        it 'should record win for email experiments' do
          EmailExperiments.any_instance.should_receive(:win!)
          sign_petition params
        end

        it 'should update sent email record with the signature_id value' do
          sign_petition params
          ScheduledEmail.last.signature_id.should == Signature.last.id
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

    context 'with social tracking parameters' do
      let(:member) { create :member }
      let(:code)   { create :referral, member: member, petition: petition }
      let(:params) { { referer_ref_type: Signature::ReferenceType::FACEBOOK_REQUEST, referer_ref_code: ref_code } }

      shared_examples 'the social media trial wins' do
        specify do
          code.reload.all_tests.first[:arms].first.values_at(:spins, :wins).should == [ 1, 0 ]
          sign_petition params
          code.reload.all_tests.first[:arms].first.values_at(:spins, :wins).should == [ 1, 1 ]
        end
      end

      before {
        petition.petition_titles.build title_type: PetitionTitle::TitleType::FACEBOOK, title: "better title"
        petition.petition_titles.build title_type: PetitionTitle::TitleType::FACEBOOK, title: "worse title"
        petition.save
        code.title
      }

      context 'with an old tracking parameter' do
        let(:ref_code) { member.to_hash }
        it_behaves_like 'the social media trial wins'
      end

      context 'with a new arbitrarily-generated tracking parameter' do
        let(:ref_code) { code.code }
        it_behaves_like 'the social media trial wins'
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
        SignedPetitionEmailJob.should_receive(:perform_async).with(anything)
        sign_petition
      end
    end

    context 'when an error occurs while saving the signature' do
      before do
        Signature.any_instance.stub(:save!).and_raise 'bang!'
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
