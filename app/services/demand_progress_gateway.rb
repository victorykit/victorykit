class DemandProgressGateway
  
  def self.fetch_unsubscribers_since(last_updated)
    sql = ActiveRecord::Base.establish_connection(Settings.demand_progress.db_uri)
    results = sql.execute("select email, core_action.created_at from core_action join core_unsubscribeaction on (core_action.id = core_unsubscribeaction.action_ptr_id) join core_user on (core_user.id = core_action.user_id) where core_action.created_at > '" + last_updated.to_s + "' order by created_at desc")
    
    #todo: something like this in stub
    #results = [ {"email"=>"foo1@bar.com", "created_at"=>1.day.ago}, {"email"=>"dodo@email.com", "created_at"=>2.days.ago} ]
    results.map { |x| UnsubscribeRequest.new(x["email"], x["created_at"])}
  end
  
  class UnsubscribeRequest
    attr_accessor :email, :created_at
    
    def initialize(email, created_at)
      @email = email
      @created_at = created_at
    end
  end

end