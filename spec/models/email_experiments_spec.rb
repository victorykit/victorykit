require 'spec_helper'

describe EmailExperiments do
  before :each do
    @default_title = "my petition title"
    @petition = create(:petition, title: @default_title)
    @email = create(:sent_email, petition: @petition)
    @experiments = EmailExperiments.new(@email)
  end

  context "title" do

    it "should return alternate value when alternates exist" do
      alternate = create(:petition_title, petition_id: @petition.id, title_type: PetitionTitle::TitleType::EMAIL)
      @experiments.subject.should eq alternate.title
    end

    it "should return petition title when no alternates exist" do
      @experiments.subject.should eq @default_title
    end

    describe "multiple calls" do

      before :each do
        create(:petition_title, petition_id: @petition.id, title: "A", title_type: PetitionTitle::TitleType::EMAIL)
        create(:petition_title, petition_id: @petition.id, title: "B", title_type: PetitionTitle::TitleType::EMAIL)
      end

      it "should return a consistent title once spun" do
        once = @experiments.subject
        twice = @experiments.subject
        once.should eq twice
      end

      it "should record a single trial for this email and petition" do
        @experiments.subject
        @experiments.subject
        EmailExperiment.all.count.should eq 1
      end

    end
  end

  context "win" do
    it "should win for all its trials" do
      test_name = "petition #{@petition.id} email title"
      trial_a = create(:email_experiment, sent_email_id: @email.id, goal: :signature, key: test_name, choice: "walnuts")
      trial_b = create(:email_experiment, sent_email_id: @email.id, goal: :something_else, key: test_name, choice: "pecans")
      other_email = create(:sent_email)
      trial_c = create(:email_experiment, sent_email_id: other_email.id, goal: :signature, key: test_name, choice: "whatever")

      @experiments.should_receive(:win_on_option!).once.with(trial_a.key, trial_a.choice, {:session_id => @email.id.to_s})
      @experiments.should_not_receive(:win_on_option!).with(trial_b.key, trial_b.choice, {:session_id => @email.id.to_s})
      @experiments.should_not_receive(:win_on_option!).with(trial_c.key, trial_c.choice, {:session_id => other_email.id.to_s})

      @experiments.win! :signature
    end
  end

end
