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

  context "win" do
    it "should win for all its trials" do
      trial = create(:social_media_trial, petition: @petition, member: @member, key: "petition #{@petition.id} facebook title")
      trial2 = create(:social_media_trial, petition: @petition, member: @member, key: "petition #{@petition.id} facebook title")
      unrelated_trial = create(:social_media_trial, petition: @petition, member: @member, key: "something not facebooky")

      @experiments.should_receive(:win_on_option!).once.with(trial.key, trial.choice, {:session_id => @member.id.to_s})
      @experiments.should_receive(:win_on_option!).once.with(trial2.key, trial2.choice, {:session_id => @member.id.to_s})
      @experiments.should_not_receive(:win_on_option!).with(unrelated_trial.key, unrelated_trial.choice, {:session_id => @member.id.to_s})

      @experiments.win!
    end
  end

end