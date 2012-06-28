require 'whiplash'

describe "to1if0" do
  it "should preserve nonzero" do
    to1if0(5).should == 5
    to1if0(nil).should == nil
  end
  it "should convert zero to one" do
    to1if0(0).should == 1
  end
end

describe "Array.mean" do
  it "should properly calculate means" do
    [5].mean.should == 5
    [0, 4].mean.should == 2
    [0, 100, 100, 100].mean.should == 75
  end
end

describe Bandit do
  include Bandit
  it "should guess floats" do
    arm_guess(0, 0).class.should == Float
    arm_guess(1, 0).class.should == Float
    arm_guess(2, 1).class.should == Float
    arm_guess(1000, 5).class.should == Float
  end
  
  it "should pick one of the options as the best" do
    best_guess({a: [10, 5], b: [100, 99]}).should be_in [:a, :b]
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