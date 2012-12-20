describe Admin::StatsController do
  context "GET daily_facebook_insight" do
    before { FbGraph::Domain.stub(:search => [stub(:insights => [insight], :access_token= => nil)]) }

    let(:insight) {
      stub(
        :name => 'domain_stories',
        :values => [{"value"=>300, "end_time"=>"2012-11-19T08:00:00+0000"}, {"value"=>200, "end_time"=>"2012-11-20T08:00:00+0000"}]
      )
    }

    let(:action) { get :daily_facebook_insight, :metrics => '' }
    it_behaves_like "a super-user only resource page"

    it "formats facebook data for dataTables" do
      get :daily_facebook_insight, {:metrics => 'domain_stories'}, valid_super_user_session

      metric = JSON.parse(response.body).first
      metric['label'].should == 'Domain Stories'
      metric['data'].should == [[1353312000000, 300], [1353398400000, 200]]
    end
  end

  context "GET email_by_time_of_day" do
    let(:action) { get :email_by_time_of_day }
    it_behaves_like "a super-user only resource page"
  end
end