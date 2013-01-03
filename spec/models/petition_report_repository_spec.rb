describe PetitionReportRepository do
  let(:repository) { PetitionReportRepository.new }

  before do
    report_with_more_likes = {
      :petition_id => 1,
      :petition_title => 'More Likes',
      :sent_emails_count_month => 8,
      :like_count_month => 4,
      :like_rate_month => 0.5
    }
    report_with_less_likes = {
      :petition_id => 2,
      :petition_title => 'Less Likes',
      :sent_emails_count_month => 24,
      :like_count_month => 6,
      :like_rate_month => 0.25
    }
    @petition_with_more_likes = create(:petition_report, report_with_more_likes)
    @petition_with_less_likes = create(:petition_report, report_with_less_likes)
  end

  context "when property has time span" do
    it "retrieves petitions sorted by property" do
      petitions = repository.reports('month', 'like_rate', :asc)
      petitions.map(&:petition_id).should eq [@petition_with_less_likes.petition_id, @petition_with_more_likes.petition_id]
    end

    it "retrieves petitions sorted by property descending" do
      petitions = repository.reports('month', 'like_rate', :desc)
      petitions.map(&:petition_id).should eq [@petition_with_more_likes.petition_id, @petition_with_less_likes.petition_id]
    end
  end

  context "when property does not have time span" do
    it "retrieves petitions sorted by property" do
      petitions = repository.reports('month', 'petition_title', :asc)
      petitions.map(&:petition_id).should eq [@petition_with_less_likes.petition_id, @petition_with_more_likes.petition_id]
    end

    it "retrieves petitions sorted by property descending" do
      petitions = repository.reports('month', 'petition_title', :desc)
      petitions.map(&:petition_id).should eq [@petition_with_more_likes.petition_id, @petition_with_less_likes.petition_id]
    end
  end

  context "totals" do
    subject { totals = repository.totals('month') }

    its(:petition_title)      { should eq 'All Petitions' }
    its(:petition_id)         { should be_nil }
    its(:petition_created_at) { should be_nil }
    its(:like_count)          { should eq 10 }
    its(:like_rate)           { should eq 0.3125 }
  end
end