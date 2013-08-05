class Admin::StatsController < ApplicationController
  include ApplicationMetrics
  before_filter :require_admin

  def browser_usage
    signature_count = Signature.count
    results = Signature.count(:group => "browser_name", :order => "count_all desc")
    @browser_stat = Hash[results.map {|k,v| [k, "%2.2f" % [v.to_f*100/signature_count]]}]
  end

  def metrics
  end

  def facebook
  end

  def nps_by_day
    render json: [{data: nps.each_with_index.map{|h, i| [i, h]}.select{|i, h| h < 1 and not [102,103,104].include?(i) }}]
  end

  def opened_emails
    render json: [{data: opened_emails_percentage.each_with_index.map { |x,i| [i, x] }}]
  end

  def clicked_emails
    render json: [{data: clicked_email_links_percentage.each_with_index.map { |x,i| [i, x] }}]
  end

  def email_response_rate
    render json: email_response_rate_by_part(params[:date_part])
  end

  def signature_activity
    render json: signatures_by_part(params[:date_part])
  end

  def daily_browser_usage
    signatures = Signature
                  .select("COUNT(*) AS count_all, browser_name, date(created_at) as created_date")
                  .where('created_at > ?', 2.weeks.ago)
                  .group("browser_name, created_date")
                  .order(:created_date)
    data = signatures.group_by(&:browser_name).map do |browser, signatures|
      { label: browser, data: signatures.map {|s| [ js_timestamp(s.created_date), s.count_all ]} }
    end

    render json: data
  end

  def daily_facebook_insight
    social_media_config = Rails.configuration.social_media
    fb_app = FbGraph::Application.new(social_media_config[:facebook][:app_id], :secret => social_media_config[:facebook][:secret])
    domain = FbGraph::Domain.search('act.watchdog.net').first
    domain.access_token = fb_app.access_token

    metrics = params[:metrics].split(',')
    start_time = 45.days.ago.beginning_of_day.to_i
    end_time   = 1.day.ago.end_of_day.to_i

    insights = domain.insights(:metric => metrics, :period => :day, :since => start_time, :until => end_time)
    data = insights.map do |i|
      {label: i.name.titleize, data: i.values.map {|v| [js_timestamp(v['end_time']), v['value']] }}
    end

    render json: data
  end

  def email_by_time_of_day
    sent_emails = ScheduledEmail.joins('INNER JOIN signatures ON sent_emails.member_id = signatures.referer_id AND signatures.petition_id = sent_emails.petition_id')
                  .where('sent_emails.created_at > ?', 10.days.ago)
    signatures_by_hour = []

    (0..23).each do |h|
      signatures_by_hour << [h, sent_emails.collect{ |se| se.id if se.created_at.hour <= h and se.created_at.hour >= h }.compact.count]
    end

    render json: [{data: signatures_by_hour}]
  end

  private

  def js_timestamp(date_string)
    date_string.to_time.to_i * 1000
  end

  def email_response_rate_by_part part
    sent_emails_by_time = ScheduledEmail.count(:group => "date_part('#{part}', created_at)")
    signed_emails_by_part = ScheduledEmail.count(:group => "date_part('#{part}', created_at)", :conditions => ['signature_id is not null'])

    spins = sent_emails_by_time.map{|k,v|[k.to_i,v]}.sort_by &:first
    wins = signed_emails_by_part.map{|k,v|[k.to_i,v]}.sort_by &:first
    response_rates = []
    spins.zip(wins) {|spin, win| response_rates << [spin[0], win[1].to_f / spin[1].to_f]}

    [{ data: response_rates }]
  end

  def signatures_by_part part
    q = Signature.count(:group => "date_part('#{part}', signatures.created_at)", :joins => :sent_email)
    [{data: q.map{|(k,v)| [k.to_i,v]}.sort_by(&:first)}]
  end

  def nps
    sent = Hash[ScheduledEmail.count(group: 'date(created_at)').map {|(k,v)| [k.to_date, v.to_f]}]
    sent.default = 1

    chart_for_table = Proc.new do |table, conditions=nil, subtract_unsubs=false|
      prefs = {group: 'date(created_at)', conditions: conditions}
      out = Hash[table.count(prefs).map {|(k,v)| [k.to_date, v.to_f]}]
      out.default = 0
      if subtract_unsubs
        #NOTE: This does not include resubscribes, but there aren't many of those.
        unsubs = Hash[Unsubscribe.count(group: 'date(created_at)').map {|(k,v)| [k.to_date, v.to_f]}]
        unsubs.default = 0
      end
      (Date.new(2012, 06, 02)..Date.today).collect do |x|
        n = out[x]
        n -= unsubs[x] if subtract_unsubs
        n/sent[x]
      end
    end

    #chart_for_table.call ScheduledEmail, 'opened_at is not null'
    #chart_for_table.call ScheduledEmail, 'clicked_at is not null'
    #chart_for_table.call ScheduledEmail, 'signature_id is not null'
    #chart_for_table.call Signature, 'referer_id != member_id'
    #chart_for_table.call Signature, "user_agent like '%MSIE%'"
    #chart_for_table.call Signature
    #chart_for_table.call Signature, 'created_member is not true'

    chart_for_table.call Signature, 'created_member is true and (referer_id is null or referer_id != 79459)', true
  end
end
