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

  context "sender experiment" do
    context "running for the first time for this email" do
      it "should spin" do
        @experiments.should_receive(:spin!).with("different from lines for scheduled emails", :signature, [Settings.email.from_address, Settings.email.from_address2, Settings.email.from_address3,
                Settings.email.from_address4, Settings.email.from_address5, Settings.email.from_address6]).and_return("choice")
        @experiments.sender.should == "choice"
      end
      it "should create an EmailExperiment record" do
        @experiments.stub(:spin!).and_return("choice")
        @experiments.sender
        experiment_record = EmailExperiment.last
        experiment_record.key.should == "different from lines for scheduled emails"
        experiment_record.choice.should == "choice"
        experiment_record.goal.should == "signature"
      end
    end

    context "running not for the first time for this email" do
      it "should not spin" do
        create(:email_experiment, :key => "different from lines for scheduled emails", :choice => "choice", :goal => "signature", :sent_email => @email)
        @experiments.should_not_receive(:spin!)
        @experiments.sender.should == "choice"
      end
    end
  end

  context "image" do
    it "should return image url when images exist" do
      image = create(:petition_image, petition_id: @petition.id)
      @experiments.image_url.should eq image.url
    end

    it "should return nil when no images exist" do
      @experiments.image_url.should be_nil
    end
  end

  context "demand progress introduction" do 
    it "should return false if no email has previously been opened, clicked or signed" do
      @experiments.should_not_receive(:spin!)
      @experiments.demand_progress_introduction.should be_false
    end
    it "should return true if member has previously signed and choice is to hide" do
      create(:signature, :email => @email.email)
      create(:email_experiment, :key => "hide demand progress introduction in email", :choice => "hide", :goal => "signature", :sent_email => @email)
      @experiments.demand_progress_introduction.should be_true
    end
    it "should return true if member has previously opened email and choice is to hide" do
      create(:sent_email, email: @email.email, opened_at: Time.now)
      create(:email_experiment, :key => "hide demand progress introduction in email", :choice => "hide", :goal => "signature", :sent_email => @email)
      @experiments.demand_progress_introduction.should be_true
    end
    it "should return false if member has previously clicked email and choice is to show" do
      create(:sent_email, email: @email.email, clicked_at: Time.now)
      create(:email_experiment, :key => "hide demand progress introduction in email", :choice => "show", :goal => "signature", :sent_email => @email)
      @experiments.demand_progress_introduction.should be_false
    end
  end

  context "win" do
    it "should win for all its trials" do
      test_name = "petition #{@petition.id} email title"
      trial_a = create(:email_experiment, sent_email_id: @email.id, goal: :signature, key: test_name, choice: "walnuts")
      trial_b = create(:email_experiment, sent_email_id: @email.id, goal: :something_else, key: test_name, choice: "pecans")
      other_email = create(:sent_email)
      trial_c = create(:email_experiment, sent_email_id: other_email.id, goal: :signature, key: test_name, choice: "whatever")
      trial_d = create(:email_experiment, sent_email: @email, goal: :signature, key: "different from lines for scheduled emails", choice: "choice")

      @experiments.should_receive(:win_on_option!).once.with(trial_a.key, trial_a.choice)
      @experiments.should_not_receive(:win_on_option!).with(trial_b.key, trial_b.choice)
      @experiments.should_not_receive(:win_on_option!).with(trial_c.key, trial_c.choice)
      @experiments.should_receive(:win_on_option!).once.with(trial_d.key, trial_d.choice)

      @experiments.win! :signature
    end
  end

end
