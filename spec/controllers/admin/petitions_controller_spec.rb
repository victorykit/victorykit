module Admin
  describe PetitionsController do
    before do
      stub_bandit controller
    end
    describe "GET index" do
      let(:action) { get :index }
      it_behaves_like "an admin only resource page"
    end
  end
end
