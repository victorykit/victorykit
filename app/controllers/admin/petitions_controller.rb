class Admin::PetitionsController < ApplicationController
  def index
    @petition_analytics = PetitionAnalytic.all
  end
end
