require 'spec_helper'
require 'signature_hasher'

describe PetitionsController do

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
    
    context "the user has already signed the petition" do
      it "sets facebook ref hash to encoded signature id" do
        controller.stub(session: {last_signature_id: petition.id})
        get :show, {:id => petition.id}
        assigns(:fb_tracking_hash).should == SignatureHasher.generate(petition.id)
      end

      it "assigns a signature name and email to the view" do
        controller.stub(session: {signature_name: "Bob", signature_email: "bob@bob.com"})
        get :show, {:id => petition.id}
        assigns(:signature).name.should == "Bob"
        assigns(:signature).email.should == "bob@bob.com"
      end

    end

    context "the user has not already signed the petition" do
      it "sets facebook ref hash to email hash if it`s present" do
        get :show, {:id => petition.id, :n => "some_hash"}
        assigns(:fb_tracking_hash).should == "some_hash"
      end

      it "sets facebook ref hash to nil if it is not present" do
        get :show, {:id => petition.id}
        assigns(:fb_tracking_hash).should be_nil
      end
    end

    context "populate signature when email hash param is present" do
      let(:member) { create :member, name: "Sven", email: "sven@svenland.se" }
      let(:sent_email) { create :sent_email, member: member }
      it "should assign values from member" do
        controller.stub(session: {signature_name: "Bob", signature_email: "bob@bob.com"})
        SentEmailHasher.stub(:validate).and_return(12)
        SentEmail.stub(:find_by_id).with(12).and_return(sent_email)
        get :show, {:id => petition.id}

        assigns(:signature).name.should == "Sven"
        assigns(:signature).email.should == "sven@svenland.se"
      end
    end
  end

  describe "GET new" do
    let(:action){ get :new }
    it_behaves_like "a login protected page"
    it "assigns a new petition as @petition" do
      get :new, {}, valid_session
      assigns(:petition).should be_a_new(Petition)
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
      get :show, id: petition.id, n: SentEmailHasher.generate(sent_email.id)
      (SentEmail.find(sent_email.id).clicked_at + 1.minute).should be > Time.now
    end

    it "should not do anything if the email hash is invalid" do
      get :show, id: petition.id, n: "invalid"
      (SentEmail.find(sent_email.id).clicked_at).should be nil
      SentEmail.find(:all).size.should == 1
    end

    it "should not update clicked_at date if it`s not empty" do
      get :show, id: petition.id, n: SentEmailHasher.generate(sent_email.id)
      first_time = SentEmail.find(sent_email.id).clicked_at
      get :show, id: petition.id, n: SentEmailHasher.generate(sent_email.id)
      SentEmail.find(sent_email.id).clicked_at.should == first_time
    end
  end
end
