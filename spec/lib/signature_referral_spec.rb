require 'spec_helper'

describe SignatureReferral do
  context "user came from the link inside scheduled email" do
    let(:referring_member) { create :member }
    let(:email) { create :sent_email, :member => referring_member}
    let(:email_hash) { SentEmailHasher.generate(email.id) }
    let(:reference_url) { "http://act.watchdog.net/petitions/1?n=#{email_hash}" }
    let(:member) { create :member }
    let(:signature) { create :signature, member: member }

    it "should record wins for any email experiments" do
      email_experiments = mock
      EmailExperiments.stub!(:new => email_experiments)
      email_experiments.should_receive(:win!)
      SignatureReferral.new(reference_url).record! signature
    end

    it "should update sent email record with the signature_id value" do
      SignatureReferral.new(reference_url).record! signature
      SentEmail.last.signature_id.should == signature.id
    end

    it "should set referer and reference type for the signature" do
      SignatureReferral.new(reference_url).record! signature
      Signature.last.reference_type.should == Signature::ReferenceType::EMAIL
      Signature.last.referring_url.should == reference_url
      Signature.last.referer.should == referring_member
    end
  end
end
