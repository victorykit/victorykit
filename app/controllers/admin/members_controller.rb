class Admin::MembersController < ApplicationController
  newrelic_ignore
  before_filter :require_admin

  def index
    @members = Member.active.paginate(:page => params[:page], :per_page => 50).order('created_at DESC')
  end
end
