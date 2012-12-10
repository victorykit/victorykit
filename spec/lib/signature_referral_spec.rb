describe SignatureReferral do

  let(:petition) { create :petition }
  let(:signature) { create :signature, petition_id: petition.id }
  received_code = "1a2b3c"
  legacy_received_code = "123.abc"

  it "return email referer given sent mail (:n) param" do
    params = {:n => "foo"}.with_indifferent_access
    referer_ref_type, referer_ref_code = SignatureReferral.translate_raw_referral(params)
    referer_ref_type.should eq "email"
    referer_ref_code.should eq "foo"
  end

  it "return email referer given sent mail (:n) param with inadvertent punctuation included" do
    params = {:n => "foo!"}.with_indifferent_access
    referer_ref_type, referer_ref_code = SignatureReferral.translate_raw_referral(params)
    referer_ref_type.should eq "email"
    referer_ref_code.should eq "foo"
  end

  it "returns nil when translating with no relevant param " do
    params = {"irrelevant param" => "foo"}.with_indifferent_access
    referer_ref_type, referer_ref_code = SignatureReferral.translate_raw_referral(params)
    referer_ref_type.should be nil
    referer_ref_code.should be nil
  end

  it "is not trackable without relevant params" do
    trackable = SignatureReferral.new(petition, signature).trackable?
    trackable.should be false
  end

  it "is trackable given reference type and received code" do
    params = {referer_ref_code: "1a2b3c", referer_ref_type: Signature::ReferenceType::EMAIL}.with_indifferent_access
    SignatureReferral.new(petition, signature, params).trackable?.should be true
  end

  it "finds email using hash given referral code having trailing punctuation" do
    sent_email = create :scheduled_email
    SentEmail.stub(:find_by_hash).with(received_code).and_return(sent_email)
    params = {referer_ref_code: "#{received_code}!", referer_ref_type: Signature::ReferenceType::EMAIL}.with_indifferent_access
    referral = SignatureReferral.new(petition, signature, params).referral
    referral[:referer].should eq sent_email.member
    referral[:reference_type].should eq Signature::ReferenceType::EMAIL
  end

  context "unresolvable referral codes" do

    it "logs warning and returns default for email referral when email unresolved" do
      SentEmail.stub(:find_by_hash).with(received_code).and_return(nil)
      Rails.logger.should_receive(:warn).with(/SentEmail record not found for referral code 1a2b3c/)
      params = {referer_ref_code: received_code, referer_ref_type: Signature::ReferenceType::EMAIL}.with_indifferent_access
      referral = SignatureReferral.new(petition, signature, params).referral
      referral.should be_empty
    end

    it "logs warning and returns default for legacy shared link referral when member unresolved" do
      Member.stub(:find_by_hash).with(legacy_received_code).and_return(nil)
      Rails.logger.should_receive(:warn).with(/Neither member nor Referral record not found for referral code 1a2b3c/)
      params = {referer_ref_code: received_code, referer_ref_type: Signature::ReferenceType::SHARED_LINK}.with_indifferent_access
      referral = SignatureReferral.new(petition, signature, params).referral
      referral.should be_empty
    end

    it "logs warning and returns default for shared link referral when member and referral code unresolved" do
      Referral.stub(:where).with("code = '1a2b3c'").and_return([])
      Rails.logger.should_receive(:warn).with(/Neither member nor Referral record not found for referral code 1a2b3c/)
      params = {referer_ref_code: received_code, referer_ref_type: Signature::ReferenceType::SHARED_LINK}.with_indifferent_access
      referral = SignatureReferral.new(petition, signature, params).referral
      referral.should be_empty
    end

    it "logs warning and returns default for share special case facebook referral when facebook action unresolved" do
      Share.stub(:find_by_action_id).with(received_code).and_return(nil)
      Rails.logger.should_receive(:warn).with(/FacebookAction record not found for referral code 1a2b3c/)
      params = {referer_ref_code: received_code, referer_ref_type: Signature::ReferenceType::FACEBOOK_SHARE}.with_indifferent_access
      referral = SignatureReferral.new(petition, signature, params).referral
      referral.should be_empty
    end

    it "logs warning and returns default for legacy facebook referral when member unresolved" do
      Member.stub(:find_by_hash).with(legacy_received_code).and_return(nil)
      Rails.logger.should_receive(:warn).with(/Member record not found for referral code 123.abc/)
      params = {referer_ref_code: legacy_received_code, referer_ref_type: Signature::ReferenceType::FACEBOOK_LIKE}.with_indifferent_access
      referral = SignatureReferral.new(petition, signature, params).referral
      referral.should be_empty
    end

    it "logs warning and returns default for generated facebook referral when referral unresolved" do
      Referral.stub(:where).with(code: received_code).and_return([])
      Rails.logger.should_receive(:warn).with(/Referral record not found for referral code 1a2b3c/)
      params = {referer_ref_code: received_code, referer_ref_type: Signature::ReferenceType::FACEBOOK_LIKE}.with_indifferent_access
      referral = SignatureReferral.new(petition, signature, params).referral
      referral.should be_empty
    end
  end

end
