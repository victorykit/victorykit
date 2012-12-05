require 'json'

class DonationTrackingController < ApplicationController

  def create
    win!(:donation)
    donation = DonationClick.create({
      referral_code: ReferralCode.find_by_code(params[:referral_code]),
      member: Signature.find_by_id(params[:signature_id]).try(:member),
      petition: Petition.find_by_id(params[:petition_id])
    })
    render(:nothing => true, :status => donation.valid? ? 200 : 500)
  end

  def paypal
    # extract paypal stuff to a class
    uri = URI(Settings.paypal.uri)
    Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
      req = Net::HTTP::Post.new(uri.request_uri)
      req.set_form_data(params.merge({:cmd => '_notify-validate'}))
      req['host'] = uri.host
      req['content-type'] = 'application/x-www-form-urlencoded'
      res = http.request(req)
      Rails.logger.info(res.body)
      if res.body == 'VERIFIED'
        donator = Member.where(:email => params[:payer_email]).first
        DonationClick.where(:member_id => donator, :amount => nil).last.
          update_attributes(:amount => params[:payment_gross])
        render(:nothing => true, :status => 200)
      else
        render(:nothing => true, :status => 500)
      end
    end
  end
end
