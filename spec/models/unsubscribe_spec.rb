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

  describe "analytics" do
    it "should increment unsubscribe count on create" do
      expect { create(:unsubscribe) }.to change{ $statsd.value_of("unsubscribes.count") }.from(0).to(1)
    end
  end
end