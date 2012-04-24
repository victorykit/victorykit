require 'spec_helper'

describe PetitionsController do

  # This should return the minimal set of attributes required to create a valid
  # Petition. As you add validations to Petition, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {:title => "This is a petition", :description => "This is a great petition!"}
  end
  
  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # PetitionsController. Be sure to keep this updated too.
  def valid_session
    user = User.create!(email: "bob@bob.com", password: "password", password_confirmation: "password")
    {:user_id => user.id}
  end

  describe "GET index" do
    it "assigns all petitions as @petitions" do
      petition = Petition.create! valid_attributes
      get :index, {}, valid_session
      assigns(:petitions).should eq([petition])
    end
  end

  describe "GET show" do
    it "assigns the requested petition as @petition" do
      petition = Petition.create! valid_attributes
      get :show, {:id => petition.to_param}, valid_session
      assigns(:petition).should eq(petition)
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
    let(:petition){ petition = Petition.create! valid_attributes }
    let(:action){ get :edit, {id: petition} }
    it_behaves_like "a login protected page"
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
        @logged_in_user = User.create!(email: "bill@creator.com", password: "foo", password_confirmation: "foo")
        post :create, {petition: valid_attributes}, {user_id: @logged_in_user.id}
      end
      describe "the newly created petition" do
        subject { assigns(:petition) }
        it { should be_persisted }
        it { should be_a(Petition) }
        its(:user) { should == @logged_in_user}
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
    let(:petition) { Petition.create! valid_attributes}
    let(:action){ put :update, {:id => petition, petition: {:title => "new title"}} }
    it_behaves_like "a login protected page"
    describe "with valid params" do
      before :each do        
        put :update, {:id => petition.to_param, :petition => {:title => "Changed title"}}, valid_session
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
        put :update, {:id => petition.to_param, :petition => {:title=>nil}}, valid_session
      end
      it "assigns the petition as @petition" do  
        assigns(:petition).should eq(petition)
      end

      it "re-renders the 'edit' template" do
        response.should render_template("edit")
      end
    end
  end

end
