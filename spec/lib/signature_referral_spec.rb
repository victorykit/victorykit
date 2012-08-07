require 'spec_helper'

describe SignatureReferral do
  context "we don`t have params in referring url" do
    let(:signature) { create :signature }
    it "shouldn't explode" do
      lambda { SignatureReferral.new(nil).record! signature }.should_not raise_error
      lambda { SignatureReferral.new("").record! signature }.should_not raise_error
      lambda { SignatureReferral.new("http://watchdog.net/petitions/1").record! signature }.should_not raise_error
      lambda { SignatureReferral.new("http://watchdog.net/petitions/1?n=").record! signature}.should_not raise_error
    end

    it "shouldn't alter the existing sent email signature" do
      lambda {
        SignatureReferral.new("http://watchdog.net/petitions/1").record! signature
      }.should_not change(signature, :referer).from(nil)
    end
  end

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

    it "should set referer and reference type if it`s not the first signature for the email" do
      email.update_attributes :signature => create(:signature)
      SignatureReferral.new(reference_url).record! signature
      Signature.last.reference_type.should == Signature::ReferenceType::EMAIL
      Signature.last.referring_url.should == reference_url
      Signature.last.referer.should == referring_member
    end

    it "should not set referer and reference type if it`s the first signature for the email" do
      SignatureReferral.new(reference_url).record! signature
      Signature.last.reference_type.should be_nil
      Signature.last.referring_url.should be_nil
      Signature.last.referer.should be_nil
    end

    it "should not record any wins if the hash is invalid" do
      email_experiments = mock
      EmailExperiments.stub!(:new => email_experiments)
      email_experiments.should_not_receive(:win!)
      wrong_reference_url = "http://act.watchdog.net/petitions/1?n=123"

      SignatureReferral.new(wrong_reference_url).record! signature
    end
  end
end
