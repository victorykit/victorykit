require_dependency 'bounce_receiver'

class IncomingMailsController < ApplicationController
  require 'mail'
    skip_before_filter :verify_authenticity_token

    def create
      message = Mail.new(params[:message])
      to_address = params[:to]
      if (to_address and to_address.to_s.start_with? 'bounce')
        Rails.logger.info "Received incoming mail correctly"
        BounceReceiver.receive_bounced_email(message.to_s, to_address.to_s)
        render :text => 'success', :status => 200
      else
        Rails.logger.info "Message failed #{message} from incorrect to address: #{to_address}"
        render :text => "Message failed #{message} from incorrect to address: #{to_address}", :status => 404
      end
    end
end