class Admin::HottestController < ApplicationController
  before_filter :require_admin

  DEMAND_PROGRESS_REFERER_ID = 79459

  def get_db_data(petition_ids=nil)
    petition_ids ||= Petition.where(to_send: true).pluck(:id)

    # for redis:
    #require "whiplash"
    #include Whiplash
    #redis_data = data_for_options("email_scheduler_nps", options)

    sent_data = ScheduledEmail.group(:petition_id).where(petition_id: petition_ids).count
    new_data = Signature.where(created_member: true).where(petition_id: petition_ids).where("(referer_id != #{DEMAND_PROGRESS_REFERER_ID} or referer_id is null)").group(:petition_id).count
    unsub_data = Unsubscribe.joins(:sent_email).group(:petition_id).where(sent_emails: { petition_id: petition_ids }).count
    sent_data.default, new_data.default, unsub_data.default = 0, 0, 0
    db_data = Hash[petition_ids.collect { |k| [k, [sent_data[k], new_data[k], unsub_data[k.to_s]]]}]
  end

  def uniqc(l)
    l.group_by{|x|x}.map{ |k, v| [k, v.length] }.sort{|x, y| y[1] <=> x[1] }
  end

  def hot_petitions w=nil
    case w
      when 'chosen'
        (1..100).map { best_guess(get_db_data) }
      when 'best'
        get_db_data.sort_by { |x| (x[1][1]-x[1][2])/x[1][0].to_f }.reverse.first(1000).map { |x| x[0] }
      when 'mine'
        Petition.select(:id).where(owner_id: params[:id] || current_user.id).order("created_at desc").limit(50).map{|x| x.id }
      else
        ScheduledEmail.limit(1000).order("id DESC").pluck("petition_id")
    end
  end

  VALID_FILTERS = ['sent', 'best', 'mine']
  DEFAULT_FILTER = 'sent'

  def index
    hotlist = hot_petitions params[:w]
    db_data = get_db_data hotlist

    acc = 0

    @rows = uniqc(hotlist).map do |x, c|
      nps = (db_data[x][1].to_f - db_data[x][2])/db_data[x][0]
      acc += nps * c
      [c, Petition.find_by_id(x), db_data[x], nps]
    end

    @avg = acc/hotlist.length.to_f
    @unique = @rows.any? && @rows[0][0] == 1
    @filter = params[:w] || DEFAULT_FILTER

    if @filter == 'mine'
      @authors = Petition.select(:owner_id).where(to_send: true).group(:owner_id).map{|x|x.owner_id}
      @myauthor = params[:id] || current_user.id.to_s
    end
  end
end
