require 'aws/ses'

class EmailGateway
  def self.send_email email
    
    ses = AWS::SES::Base.new(:access_key_id => ENV["AWS_ACCESS_KEY_ID"], :secret_access_key => ENV["AWS_SECRET_ACCESS_KEY"])
    
    ses.send_email :to      => ['jensmith@thoughtworks.com'],
                 :source    => 'jensmith@thoughtworks.com',
                 :subject   => 'A Victory for Spam!',
                 :text_body => 'I hope Amazon doesnt you charge for this'
  
    sleep 1 #- don't charge Jen's account!
  end
end
