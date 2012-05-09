require 'spec_helper'

describe UnsubscribesController do
  
  describe "GET new" do
    let(:action){ get :new }
    it "assigns a new unsubscribe as @unsubscribe" do
      get :new, {}
      assigns(:unsubscribe).should be_a_new(Unsubscribe)
    end
  end

  describe "POST create" do   
    describe "with valid params" do
      before :each do
        Unsubscribe.any_instance.stub(:save).and_return(true)
        post :create, email: "blah@blah.com", cause: "unsubscribed", :member => {email: "blah@blah.com"}
      end
      describe "the newly created unsubscribe" do
        subject { assigns(:unsubscribe) } 
        it { should be_a(Unsubscribe) }
        its(:cause) { should == "unsubscribed"}
        its(:ip_address) { should == "0.0.0.0"}
        its(:user_agent) { should == "Rails Testing"}
      end      
    end
    
    describe "with invalid params" do
      before :each do
        Unsubscribe.any_instance.stub(:save).and_return(false)
        post :create, email: "blah@blah.com", cause: "unsubscribed", :member => {email: "blah@blah.com"}
      end
      it "assigns a newly created but unsaved unsubscribe as @unsubscribe" do
        assigns(:unsubscribe).should be_a_new(Unsubscribe)
      end
      it "should redirect to new subscriber url" do
        response.should redirect_to new_unsubscribe_url
      end
    end
  end
  
end