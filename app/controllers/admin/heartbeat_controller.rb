class Admin::HeartbeatController < ApplicationController

  newrelic_ignore
  helper_method :display_content?

  def index
    last_email = SentEmail.last
    @email_threshold = ENV['VK_HEARTBEAT_SENT_EMAIL'] || 5
    @last_email_timestamp = last_email.created_at
    @email_working = @last_email_timestamp > @email_threshold.minutes.ago
    if not @email_working
      Rails.logger.error "Heartbeat: emails inactive since #{@last_email_timestamp}"
    end

    last_signature = Signature.last
    @signature_threshold = ENV['VK_HEARTBEAT_SIGNATURE'] || 60
    @last_signature_timestamp = last_signature.created_at
    @signature_working = @last_signature_timestamp > @signature_threshold.minutes.ago
    if not @signature_working
      Rails.logger.error "Heartbeat: signatures inactive since #{@last_signature_timestamp}"
    end

    @overall_working = @email_working && @signature_working
    @overall_status = "FAILING"
    @overall_status = "OK" if @overall_working
  end

  # not using 'before_filter :require_admin' because newrelic needs to be able to access this page for availability checks
  def display_content?
    debug_token_provided?
  end

end
