require 'spec_helper'

describe EmailExperiments do

  before :each do
    @default_title = "my petition title"
    @petition = create(:petition, title: @default_title)
    @email = create(:sent_email, petition: @petition)
    @experiments = EmailExperiments.new(@email)

    stub_bandit_super_spins @experiments
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

  context "image" do
    it "should return image url when images exist" do
      image = create(:petition_image, petition_id: @petition.id)
      @experiments.image_url.should eq image.url
    end

    it "should return nil when no images exist" do
      @experiments.image_url.should be_nil
    end
  end

  context "sign ask text" do
    it "should spin and return selected text" do
      @experiments.should_receive(:super_spin!).with("ask to sign text", :signature, ["Click here to sign -- it just takes a second.", "Sign this petition now.",
      "SIGN THIS PETITION", "Please, click here to sign now!"], anything()).and_return("Sign this petition now.")
      @experiments.ask_to_sign_text.should == "Sign this petition now."
    end
  end

  context "button color for sign-this-petition link" do
    it "should spin and return selected button color" do
      @experiments.should_receive(:super_spin!).with("button color for sign-this-petition link", :signature, ["#990000", "#308014"], anything()).and_return("#308014")
      @experiments.button_color_for_petition_link.should == "#308014"
    end
  end

  context "font size of sign-this-petition link" do
    it "should spin and return selected button color" do
      @experiments.should_receive(:super_spin!).with("font size of sign-this-petition link", :signature, ["100%", "125%", "150%", "200%"], anything()).and_return("150%")
      @experiments.font_size_of_petition_link.should == "150%"
    end
  end

  context "demand progress introduction" do

    context "hide" do
      it "should return false if no email has previously been opened, clicked or signed" do
        @experiments.hide_demand_progress_intro?.should be_false
      end
      it "should return true if member has previously signed" do
        create(:signature, member_id: @email.member_id)
        @experiments.hide_demand_progress_intro?.should be_true
      end
      it "should return true if member has previously opened email" do
        create(:sent_email, member_id: @email.member_id, opened_at: Time.now)
        @experiments.hide_demand_progress_intro?.should be_true
      end
      it "should return true if member has previously clicked email" do
        create(:sent_email, member_id: @email.member_id, clicked_at: Time.now)
        @experiments.hide_demand_progress_intro?.should be_true
      end
    end

    context "location" do
      it "should receive spin only introduction is not hidden" do
        @experiments.stub(:hide_demand_progress_intro?).and_return(false)
        @experiments.should_receive(:super_spin!).with("demand progress introduction location", :signature, ["top", "bottom"], anything()).and_return("bottom")
        @experiments.demand_progress_introduction_location.should == "bottom"
      end
      it "should not receive spin and default location is top if introduction is hidden" do
        @experiments.stub(:hide_demand_progress_intro?).and_return(true)
        @experiments.should_not_receive(:super_spin!)
        @experiments.demand_progress_introduction_location.should == "top"
      end
    end
  end

  context "show ps with plain text" do
    it "should return true if choice is show" do
      @experiments.should_receive(:super_spin!).with("show ps with plain text", :signature, ["show", "hide"], anything()).and_return("show")
      @experiments.show_ps_with_plain_text.should == true
    end
    it "should return false if choice is hide" do
      @experiments.should_receive(:super_spin!).with("show ps with plain text", :signature, ["show", "hide"], anything()).and_return("hide")
      @experiments.show_ps_with_plain_text.should == false
    end
  end

  context "show less prominent unsubscribe link" do
    it "should return true if choice is true" do
      @experiments.should_receive(:super_spin!).with("show less prominent unsubscribe link", :unsubscribe, [true, false], anything()).and_return(true)
      @experiments.show_less_prominent_unsubscribe_link.should == true
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

      @experiments.should_receive(:win_on_option!).once.with(trial_a.key, trial_a.choice, {:session_id => @email.id.to_s})
      @experiments.should_not_receive(:win_on_option!).with(trial_b.key, trial_b.choice, {:session_id => @email.id.to_s})
      @experiments.should_not_receive(:win_on_option!).with(trial_c.key, trial_c.choice, {:session_id => other_email.id.to_s})
      @experiments.should_receive(:win_on_option!).once.with(trial_d.key, trial_d.choice, {:session_id => @email.id.to_s})

      @experiments.win! :signature
    end
  end

end
