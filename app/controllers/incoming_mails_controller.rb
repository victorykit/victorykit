require_dependency 'email_processor'

class IncomingMailsController < ApplicationController
  require 'mail'
    skip_before_filter :verify_authenticity_token

    def create
      message = Mail.new(params[:message])
      to_address = params[:to].to_s.gsub(/[<>]/, '')

      if (to_address and to_address.to_s.start_with? 'unsubscribe')
        Rails.logger.info "Received unsubscribe email"
        EmailProcessor.handle_exceptional_email(message.to_s, to_address.to_s, 'unsubscribe')
        render :text => 'success', :status => 200
      else
        Rails.logger.info "Message failed #{message} from incorrect to address: #{to_address}"
        render :text => "Message failed #{message} from incorrect to address: #{to_address}", :status => 404
      end
    end
end
