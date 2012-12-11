class FacebookLandingPageController < ApplicationController
	
	def create
		request_id = params[:request_ids].split(',').last if params[:request_ids].present?
		facebook_request = FacebookRequest.find_by_action_id(request_id)
		if facebook_request.present?
			petition, member = facebook_request.petition, facebook_request.member
			redirect_to petition_path(petition, d: member.to_hash)
		else
			redirect_to root_path
		end
	end

	def show
  		render :text => ''
    end
end
