class Admin::StatsController < ApplicationController
  include ApplicationMetrics
  newrelic_ignore
  before_filter :require_admin

  def browser_usage
    signature_count = Signature.count
    results = Signature.count(:group => "browser_name", :order => "count_all desc")
    @browser_stat = Hash[results.map {|k,v| [k, "%2.2f" % [v.to_f*100/signature_count]]}]
  end

  def metrics
  end

  def nps_by_day
    render json: [{data:nps.each_with_index.map {|h, i| h < 1 ? [i, h] : [i, 0.01]}}]
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

  private

  def js_timestamp(date_string)
    date_string.to_time.to_i * 1000
  end

  def email_response_rate_by_part part
    sent_emails_by_time = SentEmail.count(:group => "date_part('#{part}', created_at)")
    signed_emails_by_part = SentEmail.count(:group => "date_part('#{part}', created_at)", :conditions => ['signature_id is not null'])

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
    sent = Hash[SentEmail.count(group: 'date(created_at)').map {|(k,v)| [k.to_date, v.to_f]}]
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

    #chart_for_table.call SentEmail, 'opened_at is not null'
    #chart_for_table.call SentEmail, 'clicked_at is not null'
    #chart_for_table.call SentEmail, 'signature_id is not null'
    #chart_for_table.call Signature, 'referer_id != member_id'
    #chart_for_table.call Signature, "user_agent like '%MSIE%'"
    #chart_for_table.call Signature
    #chart_for_table.call Signature, 'created_member is not true'

    chart_for_table.call Signature, 'created_member is true', true
  end
end
