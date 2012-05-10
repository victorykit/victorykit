class IncomingMailsController < ApplicationController
  require 'mail'
    skip_before_filter :verify_authenticity_token

    def create
      message = Mail.new(params[:message])
      #Rails.logger.log Logger::INFO, message.subject #print the subject to the logs
      #Rails.logger.log Logger::INFO, message.body.decoded #print the decoded body to the logs
      if (params[:envelope][:to].to_s.start_with? 'bounce-')
        BounceReceiver.receive(message.to_s)
      end
      render :text => 'success', :status => 200 # a status of 404 would reject the mail
    end
    
    def new
      message = Mail.new(params[:message])
    end
end