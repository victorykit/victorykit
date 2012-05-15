class PatchedSES < AWS::SES::Base
  def deliver!(mail, args = {})
    if mail[:source]
      args[:source] = mail[:source]
      mail[:source] = nil
    end
    AWS::SES::Base.deliver!(mail, args)
  end
end
