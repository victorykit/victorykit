class DemandProgressGateway < ActiveRecord::Base
  self.abstract_class = true
  
  def self.fetch_unsubscribers_since(date)
  	config = Rails.configuration.database_configuration["dp_production"] 
  	if config.nil?
  		Rails.logger.info "Config is nil"
  	end
  	
  	client = Mysql2::Client.new(:host => config["host"], :username => config["username"], :password => config["password"], :database => config["database"])
  	results = client.query("select email, core_action.created_at from core_action join core_unsubscribeaction on (core_action.id = core_unsubscribeaction.action_ptr_id) join core_user on (core_user.id = core_action.user_id) where core_action.created_at > '" + date.to_s + "' order by created_at desc")

  	results.to_a.map{ |row| UnsubscribeRequest.new(row["email"], row["created_at"]) }
  end

end
