class Admin::HottestController < ApplicationController
  newrelic_ignore
  before_filter :require_admin
  
  def get_db_data(options=nil)
    options ||= Petition.find_all_by_to_send(true).map { |x| x.id }
    
    # for redis:
    #require "whiplash"
    #include Whiplash
    #redis_data = data_for_options("email_scheduler_nps", options)

    sent_data = SentEmail.group(:petition_id).count
    new_data = Signature.where(created_member: true).where('(referer_id != 79459 or referer_id is null)').group(:petition_id).count
    unsub_data = Unsubscribe.joins(:sent_email).group(:petition_id).count
    sent_data.default, new_data.default, unsub_data.default = 0, 0, 0
    db_data = Hash[options.collect { |k| [k, [sent_data[k], new_data[k], unsub_data[k.to_s]]]}]
  end

  def uniqc(l)
    l.group_by{|x|x}.map{ |k, v| [k, v.length] }.sort{|x, y| y[1] <=> x[1] }
  end
  
  def hot_petitions w=nil
    case w
      when 'chosen'
        t1k_chosen = (1..100).map { best_guess(get_db_data) }
      when 'best'
        t1k_best = get_db_data.sort_by { |x| (x[1][1]-x[1][2])/x[1][0].to_f }.reverse.first(1000).map { |x| x[0] }
      when 'mine'
        Petition.select(:id).where(owner_id: params[:id] || current_user.id).order("created_at desc").limit(50).map{|x| x.id }
      else
        t1k_sent = SentEmail.last(1000).map {|x| x.petition_id}
    end
  end
  
  def index
    hotlist = hot_petitions params[:w]
    db_data = get_db_data hotlist
    
    acc = 0
    rows = []
    uniqc(hotlist).each{ |x, c|
      nps = (db_data[x][1].to_f - db_data[x][2])/db_data[x][0]
      acc += nps * c
      rows.append([c, Petition.find_by_id(x), db_data[x], nps])
    }

    @avg = acc/hotlist.length.to_f
    @rows = rows
    @unique = rows[0][0] == 1
    
    @options = ['sent', 'best', 'mine']
    @filter = params[:w] || 'sent'
    
    if @filter == 'mine'
      @authors = Petition.select(:owner_id).where(to_send: true).group(:owner_id).map{|x|x.owner_id}
      @myauthor = params[:id] || current_user.id.to_s
    end
  end
end
