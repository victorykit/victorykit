class DonationTrackingController < ApplicationController

  def create
    @petition = Petition.find params[:petition_id]
    @member = Signature.find(params[:signature_id]).member if params[:signature_id].present?
    referral_code = ReferralCode.find_by_code(params[:referral_code]) if params[:referral_code].present?
    @referral_code_id = referral_code.id if referral_code.present?

    DonationClick.create(referral_code_id: @referral_code_id, petition: @petition, member: @member)

    render :text => ''
  end

end