describe Admin::UnsubscribesController do
  describe '#index' do
    before { Unsubscribe.stub(:paginate).and_return [:unsubs] }
    before { get :index }
    it { should respond_with 200 }
    it { assigns(:unsubscribes).should == [:unsubs] }
  end
end
