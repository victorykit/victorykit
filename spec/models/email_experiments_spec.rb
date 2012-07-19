require 'spec_helper'

describe EmailExperiments do
  before :each do
    @default_title = "my petition title"
    @petition = create(:petition, title: @default_title)
    @email = create(:sent_email)
    @experiments = EmailExperiments.new(@petition, @email)
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
      trial = create(:email_experiment, sent_email_id: @email.id, key: "petition #{@petition.id} email title")
      #todo: you wouldn't actually have two title trials for the same email/petition... update once we have another email experiment
      trial2 = create(:email_experiment, sent_email_id: @email.id, key: "petition #{@petition.id} email title")
      another_email = create(:sent_email)
      another_emails_trial = create(:email_experiment, sent_email_id: another_email.id, key: "petition #{@petition.id} email title")

      @experiments.should_receive(:win_on_option!).once.with(trial.key, trial.choice, {:session_id => @email.id.to_s})
      @experiments.should_receive(:win_on_option!).once.with(trial2.key, trial2.choice, {:session_id => @email.id.to_s})
      @experiments.should_not_receive(:win_on_option!).with(another_emails_trial.key, another_emails_trial.choice, {:session_id => another_email.id.to_s})

      @experiments.win!
    end
  end

end