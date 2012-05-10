class IncomingMailsController < ApplicationController
  require 'mail'
    skip_before_filter :verify_authenticity_token

    def create
=begin
      message = Mail.new(params[:message])
      Rails.logger.log Logger::INFO, message.subject #print the subject to the logs
      Rails.logger.log Logger::INFO, message.body.decoded #print the decoded body to the logs
      to_email = params[:envelope][:to]
      if (to_email && to_email.to_s.start_with? 'bounce-')
        BounceReceiver.receive(message.to_s)
      end
      render :text => 'success', :status => 200 # a status of 404 would reject the mail
=end
    end
end