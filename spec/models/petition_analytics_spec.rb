require 'spec_helper'

describe PetitionAnalytics do
  include Rails.application.routes.url_helpers
  
  describe "initialization" do
    before :each do
      data = { petition_path(petition) => OpenStruct.new(:pageviews=>"100", :page_path=>petition_path(petition))}
      AnalyticsGateway.stub(:get_report_results){ data }      
    end
    
    let(:petition) { create(:petition_with_signatures, signature_count: 75) }
    subject { PetitionAnalytics.new(petition) }
    
    its(:hit_count) { should == 100}
    its(:signature_count) { should ==  75}
    its(:conversion_rate) { should ==  0.75}
    its(:new_member_count) { should ==  0}
    its(:virality_rate) { should ==  0.0}
  end
  
end
