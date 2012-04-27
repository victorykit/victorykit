require 'aws/ses'

class EmailGateway
  def send from, to, subject, body
    #ses = AWS::SES::Base.new(:access_key_id => 'AKIAJKCNQLB33WKHBW5Q', :secret_access_key => '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')
    
    #ses.send_email :to      => ['jensmith@thoughtworks.com'],
    #             :source    => 'jensmith@thoughtworks.com',
    #             :subject   => 'A Victory for Spam!',
    #             :text_body => 'I hope Amazon doesnt you charge for this'
  
    #sleep 1000 - don't charge Jen's account!
  end
end

class StubEmailGateway
  def send from, to, subject, body
    @last_email = {:from => from, :to => to, :subject => subject, :body => body}
  end
  def last_email_sent
    @last_email
  end
end