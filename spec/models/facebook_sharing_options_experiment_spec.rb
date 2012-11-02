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
        signature = stub("signature", :id => 5, :reference_type => referral_type, :referral_code => nil)
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

    describe "request pick vs autofill" do

      it "should skip request pick/autofill subexperiment for spin not yielding facebook_request" do
        FacebookFriend.any_instance.should_not_receive("find_by_member_id")
        whiplash.stub(:spin!).and_return("facebook_popup")
        @experiment.spin!(member, browser).should eq "facebook_popup"
      end

      context "spin yielding facebook request" do
        it "should remain facebook_request when no member given" do
          member = nil
          FacebookFriend.any_instance.should_not_receive("find_by_member_id")
          whiplash.stub(:spin!).and_return("facebook_request")
          @experiment.spin!(member, browser).should eq "facebook_request"
        end

        it "should remain facebook_request when no facebook friend exists for member" do
          FacebookFriend.stub("find_by_member_id").and_return nil
          whiplash.stub(:spin!).and_return("facebook_request")
          @experiment.spin!(member, browser).should eq "facebook_request"
        end

        it "should spin between request pick and autofill when facebook friend exists for member" do
          FacebookFriend.stub("find_by_member_id").with(member.id).and_return FacebookFriend.new
          whiplash.should_receive(:spin!).with(/facebook sharing options/, anything, anything).and_return("facebook_request")
          whiplash.should_receive(:spin!).with("facebook request pick vs autofill", anything, anything).and_return("facebook_autofill_request")
          @experiment.spin!(member, browser).should eq "facebook_autofill_request"
        end
      end

      context "win for request pick/autofill subexperiment" do

        it "should record win for facebook request against subexperiment as well as main experiment" do
          signature = stub_signature_for_referral "facebook_request", 1.month.ago.to_time
          whiplash.should_receive(:win_on_option!).with("facebook request pick vs autofill", "facebook_request")
          whiplash.should_receive(:win_on_option!).with(/facebook sharing options/, "facebook_request")
          @experiment.win!(signature)
        end

        it "should record win for autofill against subexperiment but as generic facebook request for main experiment" do
          signature = stub_signature_for_referral "facebook_autofill_request", 1.month.ago.to_time
          whiplash.should_receive(:win_on_option!).with("facebook request pick vs autofill", "facebook_autofill_request")
          whiplash.should_receive(:win_on_option!).with(/facebook sharing options/, "facebook_request")
          @experiment.win!(signature)
        end
      end

    end

  end

  def stub_signature_for_referral referral_type, referral_time
    referral_code = stub("ref code", :created_at => referral_time)
    signature = stub("signature", :id => 5, :reference_type => referral_type, :referral_code => referral_code)
  end

end
