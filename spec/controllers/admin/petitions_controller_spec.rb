describe Admin::PetitionsController do
  before { stub_bandit controller }

  describe '#index' do
    let(:action) { get :index }
    it_behaves_like 'an admin only resource page'
  end
end
