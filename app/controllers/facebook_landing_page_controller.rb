class FacebookLandingPageController < ApplicationController
	
	def new
		request_id = params[:request_ids]
		facebook_request = FacebookRequest.find_by_action_id(request_id)
		if facebook_request.present?
			petition, member = facebook_request.petition, facebook_request.member
			redirect_to petition_path(petition) + "?d=" + MemberHasher.generate(member.id)
		else
			redirect_to root_path
		end
	end
end
