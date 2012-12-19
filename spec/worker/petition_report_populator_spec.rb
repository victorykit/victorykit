require Rails.root.join("worker/petition_reports_populator.rb")

describe PetitionReportsPopulator do
  let(:petition) { create(:petition) }
  let(:report) { PetitionReport.find_by_petition_id(petition.id) }

  before do
    3.times { create(:scheduled_email, petition: petition) }
    2.times { create(:scheduled_email, petition: petition, opened_at: 1.hour.ago) }
    create(:unsubscribe, sent_email: ScheduledEmail.last)
    PetitionReportsPopulator.populate
  end

  it "creates a report for the petition" do
    report.should_not be_nil
  end

  it "counts the emails sent" do
    report.sent_emails_count_day.should eq 5
  end

  it "counts the emails opened" do
    report.opened_emails_count_day.should eq 2
  end

  it "calculates the rate of e-mails opened" do
    report.opened_emails_rate_day.should eq 0.4
  end

  it "counts unsubscribes" do
    report.unsubscribes_count_day.should eq 1
  end

  it "calculates the rate of unsubscribes" do
    report.unsubscribes_rate_day.should eq 0.2
  end
end