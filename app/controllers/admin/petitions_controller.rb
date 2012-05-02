class Admin::PetitionsController < ApplicationController
  def index
    @petition_analytics = PetitionAnalytics.all
  end
end
