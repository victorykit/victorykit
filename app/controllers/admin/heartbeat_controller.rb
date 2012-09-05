class Admin::HeartbeatController < ApplicationController

  newrelic_ignore
  helper_method :display_content?

  def index
    last_email = SentEmail.last
    @email_threshold = ENV['VK_HEARTBEAT_SENT_EMAIL'].try(:to_i) || 5
    @last_email_timestamp = last_email.created_at
    @email_working = @last_email_timestamp > @email_threshold.minutes.ago
    if not @email_working
      Rails.logger.error "Heartbeat: emails inactive since #{@last_email_timestamp}"
    end

    # Failing on a shortage of signatures turned out to be a bit overzealous, particularly in the middle of the night.
    # Instead, we'll keep it on the page so it's visible for manual checks but not fail over it. We can redefine it as
    # a ratio of signatures per page hit to take late night and holiday fluctuations into account.
    last_signature = Signature.last
    @signature_threshold = ENV['VK_HEARTBEAT_SIGNATURE'].try(:to_i) || 60
    @last_signature_timestamp = last_signature.created_at
    @signature_working = @last_signature_timestamp > @signature_threshold.minutes.ago
    if not @signature_working
      Rails.logger.warn "Heartbeat: signatures inactive since #{@last_signature_timestamp}"
    end

    @email_failing_style = "failing"
    @signature_failing_style = "warning"

    @overall_working = @email_working
    @overall_status = "FAILING"
    @overall_status = "OK" if @overall_working
    @resque_working = Resque.info[:workers] > 0
    @resque_stats = Resque.info

    @emails_sent_past_week = SentEmail.where("created_at > ?", 1.week.ago).count
    @emailable_members = Member.all.count - Unsubscribe.all.count
  end

  # not using 'before_filter :require_admin' because newrelic needs to be able to access this page for availability checks
  def display_content?
    debug_access_permitted?
  end

end
