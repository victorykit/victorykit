class Admin::PetitionsController < ApplicationController
  newrelic_ignore
  before_filter :require_admin

  def index
    respond_to do |format|
      format.html {
        @redis_used = REDIS.info["used_memory"].to_f / 104857600
      }
      format.json { render json: PetitionsDatatable.new(view_context, PetitionStatisticsBuilder.new) }
    end
  end
end
