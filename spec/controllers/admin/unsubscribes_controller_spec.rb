describe Admin::UnsubscribesController do
  describe '#index' do
    context 'no params' do
      before { get :index, {}, valid_admin_session }
      it { should respond_with 200 }
      it { should render_template :index }
    end

    context 'date range provided' do
      before { Unsubscribe.stub_chain(:between, :to_csv).and_return 'csv'}
      before do
        get :index, {:from => 3.days.ago, :to => 1.day.ago}, valid_admin_session
      end
      it { should respond_with 200 }
      its('response.body') { should == 'csv' }
    end
  end
end
