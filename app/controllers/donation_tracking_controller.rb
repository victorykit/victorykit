require 'json'

class DonationTrackingController < ApplicationController

  def create
    win! :donation
    status = DonationClick.create({
      petition: Petition.find_by_id(params[:petition_id]),
      member: Signature.find_by_id(params[:signature_id]).try(:member),
      referral_code: ReferralCode.find_by_code(params[:referral_code])
    }).valid? ? 200 : 500
    render(:nothing => true, :status => status)
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
