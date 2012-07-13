require 'spec_helper'

describe FacebookExperiments do
  before :each do
    @default_title = "my petition title"
    @petition = create(:petition, title: @default_title)
    @member = create(:member)
    @experiments = FacebookExperiments.new(@petition, @member)    
  end

  context "title" do

    it "should return alternate value when alternates exist" do
      alternate = create(:petition_title, petition_id: @petition.id, title_type: PetitionTitle::TitleType::FACEBOOK)    
      @experiments.title.should eq alternate.title
    end

    it "should return petition title when no alternates exist" do
      @experiments.title.should eq @default_title
    end

    #because we can't track the referral from a member without us having a member...
    it "should return petition title given nil member even when alternate titles exist" do
      create(:petition_title, petition_id: @petition.id, title_type: PetitionTitle::TitleType::FACEBOOK)    
      FacebookExperiments.new(@petition, nil).title.should eq @default_title
    end

    describe "multiple calls" do

      before :each do
        create(:petition_title, petition_id: @petition.id, title: "A", title_type: PetitionTitle::TitleType::FACEBOOK)    
        create(:petition_title, petition_id: @petition.id, title: "B", title_type: PetitionTitle::TitleType::FACEBOOK)    
      end

      it "should return a consistent title once spun" do
        once = @experiments.title
        twice = @experiments.title
        once.should eq twice
      end
      
      it "should record a single trial for this member and petition" do
        @experiments.title
        @experiments.title
        SocialMediaTrial.all.count.should eq 1
      end
      
    end
  end

end