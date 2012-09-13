require 'admin/application_status'

class Admin::HeartbeatController < ApplicationController

  newrelic_ignore
  helper_method :display_content?, :email_status_style, :email_status_text, :signature_status_style, :signature_status_text

  def index
    @status = ApplicationStatus.new
    @status[:email] = EmailStatus.new(true)
    @status[:signature] = SignatureStatus.new(false)
    @status[:resque] = ResqueStatus.new(true)

    @emails_sent_past_week = SentEmail.where("created_at > ?", 1.week.ago).count
    @emailable_members = Member.count - Unsubscribe.count
  end

  # not using 'before_filter :require_admin' because newrelic needs to be able to access this page for availability checks
  def display_content?
    debug_access_permitted?
  end

end
