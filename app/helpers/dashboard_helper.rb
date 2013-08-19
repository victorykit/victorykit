module DashboardHelper

  delegate :heartbeat, :nps_summary, :npfs_summary, :best_petitions, :worst_petitions,
    :nps_chart, :emails_sent_chart, :emails_opened_chart, :emails_clicked_chart, :unsubscribes_chart,
    :facebook_actions_chart, :facebook_referrals_chart, :facebook_action_per_signature_chart,
    :signatures_from_email_chart, :petition_page_load_chart, :signature_per_petition_page_load_chart,
    :timeframe, :extremes_count, :extremes_threshold, :nps_thresholds,
    :total_donations, :average_donations_per_day, :to => "@statistics"

end
