class MembersController < ApplicationController
  def new
    @member = Member.new
  end
  def create
    @member = Member.find_or_initialize_by_first_name_and_last_name_and_email(first_name: params[:member][:first_name], last_name: params[:member][:last_name], email: params[:member][:email])
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
