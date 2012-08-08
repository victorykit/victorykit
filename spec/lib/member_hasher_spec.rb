require 'spec_helper'
require 'member_hasher'

describe MemberHasher do

  it_behaves_like 'a hasher'

  describe "#member_for" do
    it "should return member instance if the hash is valid and member is present" do
      member = create(:member)
      MemberHasher.member_for(MemberHasher.generate(member.id)).should == member
    end

    it "should return nil if the hash is valid but member is not present" do
      MemberHasher.member_for(MemberHasher.generate(-1)).should be_nil
    end

    it "should return nil if the hash is invalid" do
      MemberHasher.member_for("invalid_hash").should be_nil
    end
  end
end
