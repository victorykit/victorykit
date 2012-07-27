class Admin::HottestController < ApplicationController
  newrelic_ignore
  before_filter :require_admin
  
  def get_db_data(options)
    options ||= Petition.find_all_by_to_send(true).map { |x| x.id }
    
    # for redis:
    #require "whiplash"
    #include Bandit
    #redis_data = data_for_options("email_scheduler_nps", options)
  
    sent_data = SentEmail.group(:petition_id).count
    new_data = Signature.where(created_member: true).group(:petition_id).count
    sent_data.default, new_data.default = 0, 0
    db_data = Hash[options.collect { |k| [k, [sent_data[k], new_data[k]]]}]
  end

  def uniqc(l)
    l.group_by{|x|x}.map{ |k, v| [k, v.length] }.sort{|x, y| y[1] <=> x[1] }
  end
  
  def hot_petitions
    t1k_sent = SentEmail.last(1000).map {|x| x.petition_id}
    #t1k_best = db_data.sort_by { |x| x[1][1]/x[1][0].to_f }.reverse.first(1000).map { |x| x[0] }
    #t1k_chosen = (1..1000).map { best_guess(db_data) }
  end
  
  def index
    hotlist = hot_petitions
    db_data = get_db_data hotlist
    
    acc = 0
    rows = []
    uniqc(hotlist).each{ |x, c|
      nps = db_data[x][1].to_f/db_data[x][0]
      acc += nps * c
      rows.append([c, Petition.find_by_id(x), db_data[x], nps])
    }

    @avg = acc/hotlist.length.to_f
    @rows = rows
  end
end
