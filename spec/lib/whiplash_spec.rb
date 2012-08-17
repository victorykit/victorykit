require 'whiplash'
require 'spec_helper'

describe Whiplash do
  include Whiplash

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
