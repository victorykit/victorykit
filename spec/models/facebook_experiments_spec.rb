require 'spec_helper'

describe FacebookExperiments do

  before :each do
    @default_title = "my petition title"
    @petition = create(:petition, title: @default_title)
    @member = create(:member)
    @experiments = FacebookExperiments.new(@petition, @member)    

    stub_bandit_super_spins @experiments
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

  context 'image' do
    describe 'no image is given' do
      let(:default_image) { Rails.configuration.social_media[:facebook][:images].first }
      subject { described_class.new(@petition, @member) }
      its(:image) {should == default_image}
      end
    describe 'an image is given' do
      let(:image_url) { "some_image.png" }
      let!(:petition_image) {create :petition_image, petition: @petition, url: image_url }
      subject { described_class.new(@petition, @member) }
      its(:image) {should == image_url}
    end
  end

  context "win" do
    it "should win for all its trials" do
      test_name = "petition #{@petition.id} facebook title"
      trial_a = create(:social_media_trial, petition: @petition, member: @member, goal: :signature, key: test_name, choice: "things")
      trial_b = create(:social_media_trial, petition: @petition, member: @member, goal: :something_else, key: test_name, choice: "stuff")
      other_member = create(:member)
      trial_c = create(:social_media_trial, petition: @petition, member: other_member, goal: :signature, key: test_name, choice: "etc")

      @experiments.should_receive(:win_on_option!).once.with(trial_a.key, trial_a.choice, {:session_id => @member.id.to_s})
      @experiments.should_not_receive(:win_on_option!).with(trial_b.key, trial_b.choice, {:session_id => @member.id.to_s})
      @experiments.should_not_receive(:win_on_option!).with(trial_c.key, trial_c.choice, {:session_id => @member.id.to_s})

      @experiments.win! :signature
    end
  end

end