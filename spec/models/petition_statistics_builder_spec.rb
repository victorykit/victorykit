require 'spec_helper'

describe PetitionStatisticsBuilder do
  describe "when no date is given" do
    it "should find all statistics since analytics began" do
      petition = create :petition
      old_signature = create :signature, petition: petition, created_at: ANALYTICS_START_DATE.next_month
      older_signature = create :signature, petition: petition, created_at: ANALYTICS_START_DATE
      petition_path = Rails.application.routes.url_helpers.petition_path(petition)
      
      AnalyticsGateway.should_receive(:fetch_report_results).with(ANALYTICS_START_DATE).and_return({petition_path => nil})
      stats = PetitionStatisticsBuilder.new.all_since_and_ordered(nil, "petition_title", :asc)
      stats.size.should == 1
      stats.first.signature_count.should == 2
    end
  end
end