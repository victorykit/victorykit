describe Admin::UnsubscribesController do
  describe '#index' do
    context 'no params' do
      before { get :index, {}, valid_admin_session }
      it { should respond_with 200 }
      it { should render_template :index }
    end
  end
end
