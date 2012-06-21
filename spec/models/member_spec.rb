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
	describe "subscribed" do
		it "is subscribed if subscribe date greater than unsubscribe date" do
		  subscribed_member = create :member
		  create :unsubscribe, {member: subscribed_member, created_at: 2.days.ago}
		  create :subscribe, {member: subscribed_member, created_at: 1.day.ago}

			subscribed_member.should be_subscribed
		end
		it "is subscribed if there is no unsubscribe" do
			subscribed_member = create :member
		  create :subscribe, {member: subscribed_member, created_at: 1.day.ago}

			subscribed_member.should be_subscribed
		end
		it "is unsubscribed if unsubscribe date greater than subscribe date" do
			subscribed_member = create :member
			create :subscribe, {member: subscribed_member, created_at: 2.day.ago}
			create :unsubscribe, {member: subscribed_member, created_at: 1.days.ago}

			subscribed_member.should_not be_subscribed
		end
		it "is unsubscribed if there is only an unsubscribe but no subscribe" do
			#remove when we add a subscribe record when member is created
			subscribed_member = create :member
			create :unsubscribe, {member: subscribed_member, created_at: 1.days.ago}

			subscribed_member.should_not be_subscribed
		end
	end
end