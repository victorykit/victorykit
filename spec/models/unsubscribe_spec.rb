require 'spec_helper'

describe Unsubscribe do
  describe "unsubscribe_member" do
    subject { build(:unsubscribe) }
    it { should validate_presence_of :email }
    it { should be_a(Unsubscribe) }
    it "should not be nil" do
      Unsubscribe.unsubscribe_member(Member.new).should_not == nil
    end
    it "should have a cause of unsubscribed" do
      Unsubscribe.unsubscribe_member(Member.new).cause.should == "unsubscribed"
    end
  end
end