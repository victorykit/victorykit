class Admin::DashboardController < ApplicationController
  before_filter :require_admin

  def index
    fetch_statistics
  end

  def funnel
    fetch_statistics
  end

  private

  def fetch_statistics
    @statistics = Statistics.new params.slice(:t, :x, :th)

    unless @statistics.valid?
      flash.now[:error] = @statistics.errors.full_messages
    end
  end

end
