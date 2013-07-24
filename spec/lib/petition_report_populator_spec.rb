describe PetitionReportsPopulator do
  let(:petition) { create(:petition) }

  before do
    AnalyticsGateway.stub(:fetch_report_results => {"/petitions/#{petition.id}" => OpenStruct.new(:unique_pageviews => '3')})
    3.times { create(:scheduled_email, petition: petition) }
    2.times { create(:scheduled_email, petition: petition, opened_at: 1.hour.ago) }
    create(:unsubscribe, sent_email: ScheduledEmail.last)

    PetitionReportsPopulator.populate
  end

  subject { PetitionReport.find_by_petition_id(petition.id) }

  its(:sent_emails_count_day)   { should eq 5 }
  its(:opened_emails_count_day) { should eq 2 }
  its(:opened_emails_rate_day)  { should eq 0.4 }
  its(:unsubscribes_count_day)  { should eq 1 }
  its(:unsubscribes_rate_day)   { should eq 0.2 }
  its(:hit_count_day)           { should eq 3 }
  its(:hit_rate_day)            { should eq 0.6 }
end
