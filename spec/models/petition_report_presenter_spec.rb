describe PetitionReportPresenter do
  let(:report) do
    build(:petition_report,
      :petition_title => 'My Petition',
      :sent_emails_count_week => 5,
      :like_count_week => nil,
      :like_rate_week => nil)
  end

  subject { PetitionReportPresenter.new(report, 'week') }

  its(:petition_title)    { should eq 'My Petition' }
  its(:sent_emails_count) { should eq 5 }

  it "returns Fixnum when count is nil" do
    subject.like_count.class.should eq Fixnum
  end

  it "returns Float for nil rate" do
    subject.like_rate.class.should eq Float
  end
end