describe FacebookSharingOptionsExperiment do

  let(:request){ stub("request") }
  let(:session){ stub("session", :tmp => 1) }
  let(:member){ create(:member) }

  before(:each) do
    @experiment = FacebookSharingOptionsExperiment.new(session, request)
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
        winning_option = "some option"

        @experiment.stub(:name_as_of).with(spin_time).and_return(test_name_as_of_now)
        @experiment.stub(:super_spin!).with(test_name_as_of_now, :referred_member, kind_of(Array)).and_return(winning_option)

        @experiment.spin!(member, browser).should eq winning_option
      end

      it "should win using default test name where referral code has no timestamp" do
        referral_time = nil
        default_test_name = "facebook sharing options"
        winning_option = "some option"

        @experiment.should_receive(:win_on_option!).with(default_test_name, winning_option)
        @experiment.win!(winning_option, referral_time)
      end

      it "should win using new test name where referral code has timestamp later than test transition date" do
        referral_time = Date.tomorrow.to_time
        test_name_as_of_tomorrow = "test name (reset <timestamp for tomorrow>)"
        winning_option = "some option"

        @experiment.stub(:name_as_of).with(referral_time).and_return(test_name_as_of_tomorrow)

        @experiment.should_receive(:win_on_option!).with(test_name_as_of_tomorrow, winning_option)
        @experiment.win!(winning_option, referral_time)
      end

    end

    describe "request pick vs autofill" do

      it "should skip request pick/autofill subexperiment for spin not yielding facebook_request" do
        FacebookFriend.any_instance.should_not_receive("find_by_member_id")
        @experiment.stub(:super_spin!).and_return("facebook_popup")
        @experiment.spin!(member, browser).should eq "facebook_popup"
      end

      context "spin yielding facebook request" do
        it "should remain facebook_request when no member given" do
          member = nil
          FacebookFriend.any_instance.should_not_receive("find_by_member_id")
          @experiment.stub(:super_spin!).and_return("facebook_request")
          @experiment.spin!(member, browser).should eq "facebook_request"
        end

        it "should remain facebook_request when no facebook friend exists for member" do
          FacebookFriend.stub("find_by_member_id").and_return nil
          @experiment.stub(:super_spin!).and_return("facebook_request")
          @experiment.spin!(member, browser).should eq "facebook_request"
        end

        it "should spin between request pick and autofill when facebook friend exists for member" do
          FacebookFriend.stub("find_by_member_id").with(member.id).and_return FacebookFriend.new
          @experiment.should_receive(:super_spin!).with(/facebook sharing options/, anything, anything).and_return("facebook_request")
          @experiment.should_receive(:super_spin!).with("facebook request pick vs autofill", anything, anything).and_return("facebook_autofill_request")
          @experiment.spin!(member, browser).should eq "facebook_autofill_request"
        end
      end

      context "win for request pick/autofill subexperiment" do

        it "should record win for facebook request against subexperiment as well as main experiment" do
          @experiment.should_receive(:win_on_option!).with("facebook request pick vs autofill", "facebook_request")
          @experiment.should_receive(:win_on_option!).with(/facebook sharing options/, "facebook_request")
          @experiment.win!("facebook_request", 1.month.ago.to_time)
        end

        it "should record win for autofill against subexperiment but as generic facebook request for main experiment" do
          @experiment.should_receive(:win_on_option!).with("facebook request pick vs autofill", "facebook_autofill_request")
          @experiment.should_receive(:win_on_option!).with(/facebook sharing options/, "facebook_request")
          @experiment.win!("facebook_autofill_request", 1.month.ago.to_time)
        end
      end

    end

  end

end
