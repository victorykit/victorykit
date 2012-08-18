require 'spec_helper'

module Admin

  describe PetitionsController do
    before :each do
      AnalyticsGateway.stub(:get_report_results).and_return({})
      stub_bandit controller
      REDIS.stub(:info).and_return({"used_memory" => 104857600})
    end
    describe "GET index" do
       let(:action){ get :index }
       it_behaves_like "an admin only resource page"
     end
  end
end
