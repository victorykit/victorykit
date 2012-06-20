class MembersController < ApplicationController
	def new
    @member = Member.new
	end
	def create
		@member = Member.find_or_initialize_by_email(email: params[:member][:email], name: params[:member][:name])
		if @member.save!
			subscription = Subscribe.new
	    subscription.member = @member
			subscription.save

      redirect_url = root_path
      redirect_to redirect_url, notice: "Thank you for signing up!"
    else
	    render "new"
    end
	end
end
