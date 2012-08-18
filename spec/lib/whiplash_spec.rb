require 'whiplash'
require 'spec_helper'

describe Bandit do
  include Bandit

  it "should guess floats" do
    arm_guess(0, 0).class.should == Float
    arm_guess(1, 0).class.should == Float
    arm_guess(2, 1).class.should == Float
    arm_guess(1000, 5).class.should == Float
    arm_guess(10, -2).class.should == Float
  end

  it "should pick one of the options as the best" do
    best_guess({a: [10, 5], b: [100, 99]}).should be_in [:a, :b]
  end

  it "should incr wins only for entries in given session" do
    REDIS.stub(:smembers).with("whiplash/goals/spec whiplash").and_return(["spec website layout", "spec email title"])
    website_session = {:session_id => :some_web_session, "spec website layout" => "flashy"}
    email_session = {:session_id => :some_email, "spec email title" => "hello there"}

    REDIS.should_receive(:incr).with("whiplash/spec website layout/flashy/wins")
    REDIS.should_not_receive(:incr).with("whiplash/spec email title//wins")

    win!("spec whiplash", website_session)
  end

  it "should incr wins only when choice has value" do
    website_session = {:session_id => :some_web_session, "spec website layout" => "flashy"}
    REDIS.should_not_receive(:incr)
    win_on_option!("spec whiplash layout", nil, website_session)
  end

  it "should decr wins only when choice has value" do
    website_session = {:session_id => :some_web_session, "spec website layout" => "flashy"}
    REDIS.should_not_receive(:decr)
    lose_on_option!("spec whiplash layout", nil, website_session)
  end

  # can't test this because it's mocked out...
  it "should not incr redis if only one option" do
  end
  
  # can't test this because it's mocked out...
  # it "should spin and win" do
  #   session = {session_id: "x"}
  #   test_name = "__test__whiplash_spec.rb"
  #   REDIS.del("whiplash/#{test_name}/true/spins")
  #   spin!(test_name, "__test__test", [true], session).should == true
  #   REDIS.get("whiplash/#{test_name}/true/spins").to_i.should == 1
  #   win!(:__test__name, session)
  #   REDIS.get("whiplash/#{test_name}/true/wins").to_i.should == 1
  # end
end
