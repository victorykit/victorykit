describe FacebookSharingOptionsExperiment do

  let(:whiplash){ stub("whiplash") }
  let(:member){ create(:member) }

  before(:each) do
    @experiment = FacebookSharingOptionsExperiment.new(whiplash)
  end

  context "referred signature" do
    it "should be applicable when referred from facebook sharing" do
      signature = stub("signature", :reference_type => "facebook_popup")
      FacebookSharingOptionsExperiment.applicable_to?(signature).should be_true
    end

    it "should not be applicable when referred from other than facebook" do
      signature = stub("signature", :reference_type => "shared_link")
      FacebookSharingOptionsExperiment.applicable_to?(signature).should be_false
    end

    it "should not be applicable when referred from unknown" do
      signature = stub("signature", :reference_type => nil)
      FacebookSharingOptionsExperiment.applicable_to?(signature).should be_false
    end
  end

  context "using ie7" do
    let(:browser){ stub("browser", :ie7? => true) }

    it "should always return facebook_popup" do
      @experiment.spin!(member, browser).should eq "facebook_popup"
    end
  end

  context "using a standards-compliant browser" do
    let(:browser){ stub("browser", :ie7? => false) }

    now = Time.now
    before(:each) do
      Time.stub(:now).and_return(now)
    end

    describe "time-banding" do

      it "should spin using test name as of now" do
        spin_time = now
        test_name_as_of_now = "test name (reset <timestamp for now>)"
        referral_type = "some option"

        @experiment.stub(:name_as_of).with(spin_time).and_return(test_name_as_of_now)
        whiplash.stub(:spin!).with(test_name_as_of_now, :referred_member, kind_of(Array)).and_return(referral_type)

        @experiment.spin!(member, browser).should eq referral_type
      end

      it "should win using default test name where no referral code found" do
        default_test_name = "facebook sharing options"
        referral_type = "some option"
        signature = stub("signature", :id => 5, :reference_type => referral_type, :referral => nil)
        whiplash.should_receive(:win_on_option!).with(default_test_name, referral_type)
        @experiment.win!(signature)
      end

      it "should win using default test name where referral code has no timestamp" do
        default_test_name = "facebook sharing options"
        referral_type = "some option"
        referral_time = nil
        signature = stub_signature_for_referral referral_type, referral_time
        whiplash.should_receive(:win_on_option!).with(default_test_name, referral_type)
        @experiment.win!(signature)
      end

      it "should win using new test name where referral code has timestamp later than test transition date" do
        test_name_as_of_tomorrow = "test name (reset <timestamp for tomorrow>)"
        referral_type = "some option"
        referral_time = Date.tomorrow.to_time
        signature = stub_signature_for_referral referral_type, referral_time

        @experiment.stub(:name_as_of).with(referral_time).and_return(test_name_as_of_tomorrow)

        whiplash.should_receive(:win_on_option!).with(test_name_as_of_tomorrow, referral_type)
        @experiment.win!(signature)
      end
    end
  end

  def stub_signature_for_referral referral_type, referral_time
    referral = stub("ref code", :created_at => referral_time)
    stub("signature", :id => 5, :reference_type => referral_type, :referral => referral)
  end

end
