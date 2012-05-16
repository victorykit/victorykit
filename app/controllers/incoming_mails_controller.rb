require_dependency 'bounce_receiver'

class IncomingMailsController < ApplicationController
  require 'mail'
    skip_before_filter :verify_authenticity_token

    def create
      message = Mail.new(params[:message])
      to_address = params[:to]
      if (to_address and to_address.to_s.start_with? 'bounce')
        BounceReceiver.receive_bounced_email(message.to_s, to_address.to_s)
      end
      render :text => 'success', :status => 200 # a status of 404 would reject the mail
    end
end