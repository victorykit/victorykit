describe PetitionReportPresenter do
  let(:report) { build(:petition_report, :petition_title => 'My Petition', :sent_emails_count_week => 5) }

  subject { PetitionReportPresenter.new(report, 'week') }

  its(:petition_title)    { should eq 'My Petition' }
  its(:sent_emails_count) { should eq 5 }
end