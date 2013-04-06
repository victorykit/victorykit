describe Admin::UnsubscribesController do

  describe '#index' do
    before { Unsubscribe.stub_chain(:recent_first, :paginate).and_return [:unsubs] }
    before { get :index, {}, valid_admin_session }
    it { should respond_with 200 }
    it { assigns(:unsubscribes).should == [:unsubs] }
  end

end
