require 'spec_helper'

describe UnsubscribesController do
  
  describe "GET new" do
    let(:action){ get :new }
    it "assigns a new unsubscribe as @unsubscribe" do
      get :new, {}
      assigns(:unsubscribe).should be_a_new(Unsubscribe)
    end
  end

=begin
  describe "POST create" do
    
    let(:action){ post :create }

    describe "with valid params" do
      before(:each) do
        post :create, {unsubscribe: valid_attributes}
      end
      describe "the newly created unsubscribe" do
        subject { assigns(:unsubscribe) }
        it { should be_a(Unsubscribe) }
        its(:cause) { should == "unsubscribed"}
      end
      its(:response) { response.should redirect_to(root_url) }
    end
  end
=end  
end