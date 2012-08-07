require 'spec_helper'
require 'sent_email_hasher'

describe SentEmailHasher do
  it_behaves_like "a hasher"
  describe "#sent_email_for" do
    it "should return sent_email instance if the hash is valid and sent_email is present" do
      sent_email = create(:sent_email)
      SentEmailHasher.sent_email_for(SentEmailHasher.generate(sent_email.id)).should == sent_email
    end
    it "should return nil if the hash is valid but sent_email is not present" do
      SentEmailHasher.sent_email_for(SentEmailHasher.generate(1)).should be_nil
    end
    it "should return nil if the hash is invalid" do
      SentEmailHasher.sent_email_for("invalid_hash").should be_nil
    end
  end
end
