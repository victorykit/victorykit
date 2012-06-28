class DemandProgressGateway
  
  def self.fetch_unsubscribers_since(date)
    client = Mysql2::Client.new(:host => settings.host, :username => settings.username, :password => settings.password, :database => settings.database)
    results = client.query("select email, core_action.created_at from core_action join core_unsubscribeaction on (core_action.id = core_unsubscribeaction.action_ptr_id) join core_user on (core_user.id = core_action.user_id) where core_action.created_at > '" + date.to_s + "' order by created_at desc")

    results.to_a.map{ |row| UnsubscribeRequest.new(row["email"], row["created_at"]) }
  end
  
  def self.settings
    Settings.dp_connection
  end

end
