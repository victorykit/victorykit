require "spec_helper"

describe Notifications do
  describe "signed_petition" do
    let(:signature){ create(:signature) }
    let(:referer){ signature.member.to_hash }
    let(:unsubscribe_link){"http://test/unsubscribe"}
    let(:mail) { Notifications.signed_petition(signature) }
    it "renders the headers" do
      mail.subject.should match /#{signature.petition.title}/
      mail.to.should eq([signature.email])
    end

    it "renders the body" do
      mail.body.encoded.should include(signature.petition.title)
      mail.body.encoded.should include(unsubscribe_link)
    end

    let(:petition_link){"http://test/petitions/#{signature.petition.id}?r=#{referer}"}
    it "includes a member-specific link to the petition" do
      mail.body.encoded.should include(petition_link)
    end
  end

  describe "unsubscribed" do
    let(:signup_link){"http://test/subscribe"}
    let(:unsubscribe){create(:unsubscribe)}
    let(:mail) { Notifications.unsubscribed(unsubscribe) }
    it "should include a link to sign up" do
      mail.body.encoded.should include(signup_link)
    end
  end
end
