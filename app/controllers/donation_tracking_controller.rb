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

  def paypal
    uri = URI(Settings.paypal.uri)
    Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
      req = Net::HTTP::Post.new(uri.request_uri)
      req.set_form_data(params.merge({:cmd => '_notify-validate'}))

      req['host'] = uri.host
      req['content-type'] = 'application/x-www-form-urlencoded'

      res = http.request(req) 
      Rails.logger.info(res.body)
    end

    render :text => 'OK'
  end
end
