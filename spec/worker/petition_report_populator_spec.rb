require Rails.root.join("worker/petition_reports_populator.rb")

describe PetitionReportsPopulator do
  let(:petition) { create(:petition) }

  before do
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
end