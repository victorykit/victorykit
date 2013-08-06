class ActionKitUnsubscribeGateway

  def self.fetch_unsubscribers_since(date)
    client = Mysql2::Client.new(settings)

    results = client.query <<-SQL
      SELECT email, core_action.created_at
      FROM core_action
      JOIN core_unsubscribeaction ON (core_action.id = core_unsubscribeaction.action_ptr_id)
      JOIN core_user on (core_user.id = core_action.user_id)
      WHERE core_action.created_at > '#{client.escape(date.to_s)}'
      ORDER BY created_at DESC
    SQL

    results.to_a.map do |row|
      UnsubscribeRequest.new(row["email"], row["created_at"])
    end
  end

  def self.settings
    Settings.action_kit.to_hash
  end

end
