class Admin::PetitionsController < ApplicationController
  def index
    @petitions = Petition.all
  end
end
