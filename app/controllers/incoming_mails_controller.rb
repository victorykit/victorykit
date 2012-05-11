require_dependency 'bounce_receiver'

class IncomingMailsController < ApplicationController
  require 'mail'
    skip_before_filter :verify_authenticity_token

    def create
      message = Mail.new(params[:message])
      to_email = params[:to]
      message['return-path'] = to_email # used for testing only
      if (to_email and to_email.to_s.start_with? 'bounce-')
        BounceReceiver.receive(message.to_s)
      end
      render :text => 'success', :status => 200 # a status of 404 would reject the mail
    end
end