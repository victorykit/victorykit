class MembersController < ApplicationController
	def new
    @member = Member.new
	end
	def create
		@member = Member.new(params[:member])
    if @member.save
      redirect_url = root_path
      redirect_to redirect_url, notice: "Thank you for signing up!"
    else
	    render "new"
    end
	end
end
