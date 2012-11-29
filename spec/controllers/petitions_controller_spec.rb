require 'member_hasher'

describe PetitionsController do

  before(:each) do
    stub_bandit controller
    class Petition
      def sigcount
        signatures.count
      end
    end
  end

  # This should return the minimal set of attributes required to create a valid
  # Petition. As you add validations to Petition, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {:title => "This is a petition", :description => "This is a great petition!"}
  end

  describe "GET index" do
    it "assigns all petitions as @petitions" do
      petition = create(:petition)
      get :index, {}, valid_admin_session
      assigns(:petitions).should eq([petition])
    end

    let(:action){ get :index }
    it_behaves_like "an admin only resource page"
  end

  describe "GET show" do
    let(:petition) { create(:petition) }
    it "should assign petition variable" do
      get :show, {:id => petition.id}
      assigns(:petition).should == petition
    end

    it "should assign sigcount variable" do
      get :show, {:id => petition.id}
      assigns(:sigcount).should == petition.signatures.count
    end

    it "should assign email_hash variable" do
      get :show, {:id => petition.id, n: "some_hash"}
      assigns(:email_hash).should == "some_hash"
    end

    it "should set was_signed to false if cookies don`t contain this petition" do
      member = create(:member)
      controller.stub(:cookies => {member_id: member.to_hash})
      get :show, :id => petition.id.to_s
      assigns(:was_signed).should == false
    end

    it "should set was_signed to true if cookies contain this petition" do
      member = create(:member)
      controller.stub(:cookies => {member_id: member.to_hash})
      create(:signature, :member_id => member.id, :petition_id => petition.id)
      get :show, :id => petition.id.to_s
      assigns(:was_signed).should == true
    end

    it 'should specify commenters or likers for facebook recommendations' do
      ReferralCode.any_instance.stub(:prefer_commenters_to_likers).and_return(true)
      get :show, {:id => petition.id}
      assigns(:prefer_commenters_to_likers).should == true
    end

    context "the user has already signed the petition" do
      let(:member) { create(:member) }

      it "should set the id for @signature" do
        controller.stub(cookies: {:member_id => member.to_hash})
        signature = create(:signature, petition: petition, member: member)
        get :show, {:id => petition.id}
        assigns(:signature).id.should == signature.id
      end
    end

    context "the user has not already signed the petition" do
      it "sets facebook ref hash to nil" do
        get :show, {:id => petition.id}
        assigns(:current_member_hash).should be_nil
      end
    end

    context "no member cookies" do
      let(:member_sven) { create :member, first_name: "Sven", email: "sven@svenland.se" }
      let(:member_bob) { create :member, first_name: "Bob", email: "bob@bob.com" }

      context "email hash is present" do
        context "the petition was already signed from this email" do
          let(:signature) { create :signature, member: member_sven, petition: petition }
          let(:sent_email) { create :sent_email, member: member_sven, signature_id: signature.id}

          it "should not populate name and email from email_hash" do
            get :show, :id => petition.id, :n => sent_email.to_hash

            assigns(:signature).first_name.should be_nil
            assigns(:signature).last_name.should be_nil
            assigns(:signature).email.should be_nil
          end
        end

        context "the petition was not signed from this email" do
          let(:sent_email) { create :sent_email, member: member_sven, :signature_id => nil}
          it "should assign name and email to the form from email hash" do
            get :show, :id => petition.id, :n => sent_email.to_hash

            assigns(:signature).first_name.should == "Sven"
            assigns(:signature).email.should == "sven@svenland.se"
          end

          it "should run an experiment for classic vs focused layout" do
            controller.should_receive(:measure!).with('toggle layout of position page 3 for email referrals', :signature, ['classic', 'focused']).and_return('focused')
            get :show, :id => petition.id, :n => sent_email.to_hash
            assigns(:petition_layout).should == 'focused'
          end
        end
      end

      context "no email hash" do
        it "should run an experiment for classic vs focused layout" do
          controller.should_receive(:measure!).with('toggle layout of position page 3', :signature, ['classic', 'focused']).and_return('focused')
          get :show, :id => petition.id
          assigns(:petition_layout).should == 'focused'
        end
      end
    end

    context "member cookies are present" do
      let(:member_sven) { create :member, first_name: "Sven", email: "sven@svenland.se" }
      let(:member_bob) { create :member, first_name: "Bob", email: "bob@bob.com" }
      context "no email hash" do
        it "populates his name and email in the signature form from cookies" do
          controller.stub(cookies: {:member_id => member_bob.to_hash})
          get :show, {:id => petition.id}
          assigns(:signature).first_name.should == "Bob"
          assigns(:signature).email.should == "bob@bob.com"
        end
      end

      context "email hash is present" do
        context "the petition was signed from this email" do
          let(:signature) { create :signature, petition: petition, member: member_sven }
          let(:sent_email) { create :sent_email, member: member_sven, signature: signature}
          it "should assign name and email to the form from member cookies" do
            controller.stub(cookies: {member_id: member_bob.to_hash})
            get :show, {:id => petition.id, :n => sent_email.to_hash}

            assigns(:signature).first_name.should == "Bob"
            assigns(:signature).email.should == "bob@bob.com"
          end
          it "should run an experiment for classic vs focused layout" do
            controller.stub(cookies: {member_id: member_bob.to_hash})
            controller.should_receive(:measure!).with('toggle layout of position page 3 for email referrals', :signature, ['classic', 'focused']).and_return('focused')
            get :show, :id => petition.id, :n => sent_email.to_hash
            assigns(:petition_layout).should == 'focused'
          end
        end
        context "the petition was not signed from this email" do
          let(:sent_email) { create :sent_email, member: member_sven, :signature_id => nil}
          it "should assign name and email to the form from cookies" do
            controller.stub(cookies: {member_id: member_bob.to_hash})
            get :show, {:id => petition.id, :n => sent_email.to_hash}

            assigns(:signature).first_name.should == "Bob"
            assigns(:signature).email.should == "bob@bob.com"
          end
        end
      end
    end

    describe 'show' do
      render_views
      let(:petition) { create(:petition, title: "evil unsafe characters! \"&'<> ", description: "\"&'<>") }
      let(:signature) { create(:signature) }
      let(:user) { create(:user) }
      let(:member) { create(:member) }
      it 'should include opengraph meta tags' do
        response = get :show, id: petition.id
        body = Nokogiri::HTML response.body
        body.xpath('//meta[@property="og:title"]/@content').first.inner_html.should == "evil unsafe characters! \"&amp;'&lt;&gt;"
        body.xpath('//meta[@property="og:description"]/@content').first.inner_html.should == "\"&amp;'&lt;&gt;"
        body.xpath('//meta[@property="og:site_name"]/@content').first.value.should == 'Victory Kit'
        body.xpath('//meta[@property="og:type"]/@content').first.value.should == 'watchdognet:petition'
        # We want a value there, but it'll change with time.
        body.xpath('//meta[@property="og:image"]/@content').first.value.should_not be_empty
      end
    end
  end

  describe "GET new" do
    let(:action) { get :new }
    it_behaves_like "a login protected page"

    context 'user logged in' do
      let(:us) do
        stub(subregions:
          [stub(code: 'CA', name: 'California'),
           stub(code: 'NV', name: 'Nevada')])
      end

      let(:countries) do
        [stub(code: 'US', name: 'United States'),
         stub(code: 'CAN', name: 'Canada')]
      end

      before do
        Carmen::Country.stub(:all).and_return countries
        Carmen::Country.stub(:coded).with('US').and_return us
        get :new, {}, valid_session
      end

      it { should respond_with :success }
      it { assigns(:states).should == {'CA'=>'California', 'NV'=> 'Nevada'} }
      it { assigns(:countries).should == {'US'=>'United States', 'CAN'=> 'Canada'} }
      it { assigns(:petition).should be_a_new(Petition) }
      it { should render_template :new }
    end
  end

  describe "GET edit" do
    let(:petition){ create(:petition) }
    let(:action){ get :edit, {id: petition} }
    it_behaves_like "a user with edit permissions resource page"
    it "assigns the requested petition as @petition" do
      get :edit, {:id => petition.to_param}, valid_session
      assigns(:petition).should eq(petition)
    end
  end

  describe "POST create" do

    let(:action){ post :create }
    it_behaves_like "a login protected page"

    describe "with valid params" do
      before(:each) do
        @logged_in_user = create(:user)
        post :create, {petition: valid_attributes}, {user_id: @logged_in_user.id}
      end
      describe "the newly created petition" do
        subject { assigns(:petition) }
        it { should be_persisted }
        it { should be_a(Petition) }
        its(:owner) { should == @logged_in_user}
      end
      its(:response) { response.should redirect_to(Petition.last) }
    end

    describe "with invalid params" do
      before :each do
        Petition.any_instance.stub(:save).and_return(false)
        post :create, {:petition => {}}, valid_session
      end
      it "assigns a newly created but unsaved petition as @petition" do
        assigns(:petition).should be_a_new(Petition)
      end

      it "re-renders the 'new' template" do
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    let(:petition) { create(:petition) }
    let(:action){ put :update, {:id => petition, petition: {:title => "new title"}} }
    it_behaves_like "a login protected page"
    describe "with valid params" do
      before :each do
        put :update, {:id => petition.to_param, :petition => {:title => "Changed title"}}, valid_super_user_session
      end
      it "updates the requested petition" do
        petition.reload.title.should == "Changed title"
      end

      it "assigns the requested petition as @petition" do
        assigns(:petition).should eq(petition)
      end

      it "redirects to the petition" do
        response.should redirect_to(petition)
      end
    end

    describe "with invalid params" do
      before :each do
        put :update, {:id => petition.to_param, :petition => {:title=>nil}}, valid_super_user_session
      end
      it "assigns the petition as @petition" do
        assigns(:petition).should eq(petition)
      end

      it "re-renders the 'edit' template" do
        response.should render_template("edit")
      end
    end
  end

  describe "track_visit" do
    let(:sent_email) { create :sent_email }
    let(:petition) { create :petition }

    it "should update clicked_at with the current time if email hash and corresponding sent_email are present" do
      get :show, id: petition.id, n: sent_email.to_hash
      (SentEmail.find(sent_email.id).clicked_at + 1.minute).should be > Time.now
    end

    it "should not do anything if the email hash is invalid" do
      get :show, id: petition.id, n: "invalid"
      (SentEmail.find(sent_email.id).clicked_at).should be nil
      SentEmail.count.should == 1
    end

    it "should not update clicked_at date if it`s not empty" do
      get :show, id: petition.id, n: sent_email.to_hash
      first_time = SentEmail.find(sent_email.id).clicked_at
      get :show, id: petition.id, n: sent_email.to_hash
      SentEmail.find(sent_email.id).clicked_at.should == first_time
    end
  end

  describe '#again' do
    let(:cookies) { mock }

    before do
      controller.stub(:cookies).and_return cookies
      cookies.stub(:delete)
    end

    it 'should delete member cookie' do
      cookies.should_receive(:delete).with(:member_id)
      post(:again, id: 42, l: '281._4oBaT')
    end

    it 'should redirect to show with query' do
      #FIXME: think of a proper way to simulate it without forcing stub
      request.stub(:query_parameters).and_return({ l: '281._4oBaT' })
      post(:again, id: 42, l: '281._4oBaT')
      response.should redirect_to '/petitions/42?l=281._4oBaT'
    end

    it 'should increment a statsd counter' do
      expect { post(:again, id: 42, l: '281._4oBaT')}.to change{ $statsd.value_of("same_browser_signatures.count") }.from(0).to(1)
    end
  end

  describe '#petition_layouts' do
    before { controller.stub_chain(:browser, :mobile?).and_return(is_mobile) }

    context 'regular browser' do
      let(:is_mobile) { false }

      it 'spins to choose a layout' do
        controller.should_receive(:spin!).and_return('some layout')
        controller.petition_layouts.should == 'some layout'
      end
    end

    context 'mobile' do
      let(:is_mobile) { true }

      it 'renders focused' do
        controller.should_not_receive(:spin!)
        controller.petition_layouts.should == 'focused'
      end
    end

  end

end
