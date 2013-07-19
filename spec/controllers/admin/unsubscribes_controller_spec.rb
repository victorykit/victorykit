describe Admin::UnsubscribesController do
  describe '#index' do
    context 'no params' do
      before { get :index, {}, valid_admin_session }
      it { should respond_with 200 }
      it { should render_template :index }
    end
  end

  describe "with some unsubscribes" do
    let!(:unsubscribe) { FactoryGirl.create(:unsubscribe) }
    before { get :index, {from: 1.year.ago, to: 1.year.from_now, format: 'csv'}, valid_admin_session }
    it { should respond_with 200 }
  end
end
