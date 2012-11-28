describe PetitionTitlesValidator do

  it "should be valid with two different title types having same title" do
    petition = create(:petition)
    pt1 = PetitionTitle.new(title_type: PetitionTitle::TitleType::EMAIL, title: "foo");
    pt2 = PetitionTitle.new(title_type: PetitionTitle::TitleType::FACEBOOK, title: "foo");
    petition.petition_titles << pt1 << pt2
    petition.should have(0).error_on(:base)
  end

  it "should not be valid with two email subjects having same title" do
    petition = create(:petition)
    pt1 = PetitionTitle.new(title_type: PetitionTitle::TitleType::EMAIL, title: "foo");
    pt2 = PetitionTitle.new(title_type: PetitionTitle::TitleType::EMAIL, title: "foo");
    petition.petition_titles << pt1 << pt2
    petition.should have(1).error_on(:base)
    petition.errors[:base].should include "Email Subject must be unique"
  end

end