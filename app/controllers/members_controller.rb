class MembersController < ApplicationController
	def new
    @member = Member.new
	end
	def create
		@member = Member.find_or_initialize_by_name_and_email(name: params[:member][:name], email: params[:member][:email])
		if @member.valid?
			@member.save!
			subscription = Subscribe.new
	    subscription.member = @member
			subscription.save!

      redirect_to root_path, notice: "Thank you for signing up!"
		else
	    render 'new'
    end
	end
end
