require 'aws/ses'

class EmailGateway
  def self.send_new_signature_email signature
    Notifications.signed_petition signature
  end
end
