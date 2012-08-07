class SignatureReferral
  PARAMS_MAP = {"n" => Signature::ReferenceType::EMAIL}

  def initialize(referring_url)
    @referring_url = referring_url
  end

  def uri
    URI.parse(@referring_url)
  end

  def params
    @params ||= CGI.parse(self.uri.query)
  end

  def reference_param
    ( params.keys & PARAMS_MAP.keys ).first
  end

  def reference_type
    PARAMS_MAP[ self.reference_param ]
  end

  def reference_hash
    params[ self.reference_param ].first
  end

  def record!(signature)
    case self.reference_type
    when Signature::ReferenceType::EMAIL
      sent_email = SentEmailHasher.sent_email_for(reference_hash)
      sent_email.signature ||= signature
      sent_email.save!
      signature.attributes = {referer: sent_email.member, reference_type: Signature::ReferenceType::EMAIL, referring_url: @referring_url}
      EmailExperiments.new(sent_email).win!(:signature)
      signature.save!
    end
  end

end
