require "spec_helper"

describe Notifications do
  describe "signed_petition" do
    let(:signature){ create(:signature)}
    let(:mail) { Notifications.signed_petition(signature) }
    it "renders the headers" do
      mail.subject.should eq("Thanks for signing '#{signature.petition.title}'!")
      mail.to.should eq([signature.email])
      mail.from.should eq(["signups@victorykit.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

end
