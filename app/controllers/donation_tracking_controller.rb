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
    # should we move token and uri to env variables?
    token = "NJxH2Yzm_ONgyOOzgyHBSwBrq72X_KltZF1_QutkfBvQMmaJr4OuVz9uz-G"
    uri = URI('https://www.sandbox.paypal.com/cgi-bin/webscr')

    Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      req = Net::HTTP::Post.new(uri.request_uri)

      req.set_form_data(
        'cmd' => '_notify-synch', 
        'tx' => params[:tx], 
        'at' => token)
      req['host'] = uri.host
      req['content-type'] = 'application/x-www-form-urlencoded'

      res = http.request(req) # Net::HTTPResponse object
      Rails.logger.info(res.body)
    end

    render :text => 'OK'
  end
end
