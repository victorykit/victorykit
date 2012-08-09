class SignatureReferral
  PARAMS_MAP = {"n" => Signature::ReferenceType::EMAIL}

  def initialize(referring_url)
    @referring_url = referring_url
  end

  def uri
    @uri ||= URI.parse(@referring_url) rescue nil
  end

  def params
    @params ||= self.uri.try(:query).blank? ? {} : CGI.parse(self.uri.query)
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
    return if params.empty?

    case self.reference_type
    when Signature::ReferenceType::EMAIL
      sent_email = SentEmail.find_by_hash(reference_hash)
      return if sent_email.blank?

      if sent_email.signature.present?
        signature.update_attributes(
          referer: sent_email.member,
          reference_type: Signature::ReferenceType::EMAIL,
          referring_url: @referring_url
        )
      else
        sent_email.update_attributes(signature: signature)
      end

      EmailExperiments.new(sent_email).win!(:signature)
    end
  end

end
