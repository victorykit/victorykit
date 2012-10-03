require 'spec_helper'

describe ReferralCode do
  let(:rc) { build :referral_code }
  subject { rc }

  its(:code) { should_not be_blank }
  its(:session) { subject.to_hash.should eq(:session_id => rc.code) }

  describe "#spin!" do
    let(:choice) { subject.spin! "test name", :goal, [:thing1, :thing2] }
    let(:data) { subject.data_for_options("test name", [:thing1, :thing2]) }
    before { choice }

    its(:new_record?) { should_not be_true }
    its(:session) { subject.to_hash.should include("test name" => choice) }
    its(:social_media_trials) { should have(1).element }

    specify { data[choice].should == [1, 0] }

    describe "#win!" do
      before { subject.win! :goal }
      specify { data[choice].should == [1, 1] }
    end
  end

  context "with a member" do
    let(:member) { create(:member) }
    subject { ReferralCode.new member: member }
    its(:code) { should eq member.to_hash }
  end
end