require 'spec_helper'

describe Admin::PetitionsController do

  describe "GET index" do
    it "assigns all petitions as @petitions" do
      petition = create(:petition)
      get :index, {}, valid_session
      assigns(:petitions).should eq([petition])
    end
  end

end
