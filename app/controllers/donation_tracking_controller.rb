require 'json'

class DonationTrackingController < ApplicationController

  def create
    win! :donation
    @petition = Petition.find params[:petition_id]
    @member = Signature.find(params[:signature_id]).member if params[:signature_id].present?
    referral_code = ReferralCode.find_by_code(params[:referral_code]) if params[:referral_code].present?
    @referral_code_id = referral_code.id if referral_code.present?

    DonationClick.create(referral_code_id: @referral_code_id, petition: @petition, member: @member)

    render :text => ''
  end

  def show
    transaction_id = params[:tx]
    authToken = "NJxH2Yzm_ONgyOOzgyHBSwBrq72X_KltZF1_QutkfBvQMmaJr4OuVz9uz-G"
    if transaction_id.present?
      Rails.logger.info "*** Received transaction #{transaction_id} ***"
      
      uri = URI.parse('https://www.sandbox.paypal.com/cgi-bin/webscr')
      
      # params = "ccmd=_notify-synch&tx=#{transaction_id}&at=#{authToken}"        
      post_params = { 
        :ccmd => "_notify-synch",
        :tx => "#{transaction_id}",
        :at => "#{authToken}",
      }
      
      req = Net::HTTP::Post.new(uri.path)
      req.body = JSON.generate(post_params)
      req["Content-Type"] = "application/json"
  
      http = Net::HTTP.new(uri.host)
      response = http.start {|htt| htt.request(req)}
      Rails.logger.info "*** Received post response #{response.inspect} ***"
    else
      Rails.logger.info "*** Received nothing!!! ***"
    end
    render :text => ''
  end
end