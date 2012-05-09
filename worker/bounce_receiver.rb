require 'hasher'

class BounceReceiver < ActionMailer::Base

  #receive(mail(subject: "Failure!", to: "411.3Yj9+p@watchdog.net", status: 'Failure'))
  
  def receive(email)
    begin 
      puts "received email #{email}"
      handle_delivery_failure(email) if (email.body =~ /Status: 5/)
    rescue => error
      puts "Error in receiving bounced mail #{error}"
    end  
  end
  
  def handle_delivery_failure(email)
    address = original_to(email)
    puts "Got address #{address}"
    if (address)
      #log into Unsubscribes table 
    end
  end

  def original_to(email)
    address, domain = email.to[0].split("@")
    
    if h = Hasher.validate(address)
      sent_email = SentEmail.find_by_id(h)
      address = sent_email.email
    end

    return(address)
  end  
end