require 'spec_helper'

describe Member do
  describe "random_and_not_recently_contacted" do
    it "should ignore recently contacted members" do
      recently_contacted_member = create :member
      create :sent_email, member: recently_contacted_member
      
      Member.random_and_not_recently_contacted.should be nil
    end
    it "should select members contacted more than a week ago" do
      previously_contacted_member = create :member
      create :sent_email, created_at: 8.days.ago, member: previously_contacted_member

      Member.random_and_not_recently_contacted.should eq previously_contacted_member
    end
    it "should ignore unsubscribed members" do
      unsubscribed_member = create :member
      create :unsubscribe, member: unsubscribed_member

      Member.random_and_not_recently_contacted.should be nil
    end
  end
end