describe PetitionReportRepository do
  let(:repository) { PetitionReportRepository.new }

  before do
    @petition_with_more_likes = create(:petition_report, :petition_id => 1, :petition_title => 'More Likes', :like_rate_month => 0.5)
    @petition_with_less_likes = create(:petition_report, :petition_id => 2, :petition_title => 'Less Likes', :like_rate_month => 0.3)
  end

  context "when property has time span" do
    it "retrieves petitions sorted by property" do
      petitions = repository.all_since_and_ordered('month', 'like_rate', :asc)
      petitions.map(&:petition_id).should eq [@petition_with_less_likes.petition_id, @petition_with_more_likes.petition_id]
    end

    it "retrieves petitions sorted by property descending" do
      petitions = repository.all_since_and_ordered('month', 'like_rate', :desc)
      petitions.map(&:petition_id).should eq [@petition_with_more_likes.petition_id, @petition_with_less_likes.petition_id]
    end
  end

  context "when property does not have time span" do
    it "retrieves petitions sorted by property" do
      petitions = repository.all_since_and_ordered('month', 'petition_title', :asc)
      petitions.map(&:petition_id).should eq [@petition_with_less_likes.petition_id, @petition_with_more_likes.petition_id]
    end

    it "retrieves petitions sorted by property descending" do
      petitions = repository.all_since_and_ordered('month', 'petition_title', :desc)
      petitions.map(&:petition_id).should eq [@petition_with_more_likes.petition_id, @petition_with_less_likes.petition_id]
    end
  end
end