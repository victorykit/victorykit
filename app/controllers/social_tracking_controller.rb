class SocialTrackingController < ApplicationController
  def new
    win! :share
    render :text => ''
  end
end