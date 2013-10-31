class Admin::DashboardController < ApplicationController
  before_filter :require_admin

  def index
    fetch_statistics
  end

  def funnel
    fetch_statistics
  end

  def show_config
    # Stupid shenanigans to pretty print with newlines
    io = PP.pp(Settings.to_hash, StringIO.new)
    io.rewind
    @settings_str = io.read

    io = PP.pp(AppSettings.instance.data, StringIO.new)
    io.rewind
    @app_settings_str = io.read

    io = PP.pp(ENV, StringIO.new)
    io.rewind
    @env_str = io.read
  end

  private

  def fetch_statistics
    @statistics = Statistics.new params.slice(:t, :x, :th)

    unless @statistics.valid?
      flash.now[:error] = @statistics.errors.full_messages
    end
  end

end
