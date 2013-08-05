require 'admin/application_status'

class Admin::HeartbeatController < ApplicationController
  helper_method :display_content?

  def index
    heartbeat = Admin::Heartbeat.new
    @status = heartbeat.status
    @emails_sent_past_week = heartbeat.emails_sent_since(1.week.ago)
    @emailable_members = heartbeat.emailable_members
  end

  # not using 'before_filter :require_admin' because newrelic needs to be able to access this page for availability checks
  def display_content?
    debug_access_permitted?
  end

end
