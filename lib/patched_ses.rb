class PatchedSES < AWS::SES::Base
  def deliver!(mail, args = {})
    if mail[:source]
      args[:source] = mail[:source].to_s
      mail[:source] = nil
    end
    AWS::SES::Base.instance_method(:deliver!).bind(self).call(mail, args)
  end
end
