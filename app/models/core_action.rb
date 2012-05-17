class CoreAction < DemandProgressGateway 
  
  self.table_name = 'core_action'
  
  def self.fetch_unsubscribers_since(last_updated)  
    @core_actions = CoreAction.find(:all,
      :select => "email, core_action.created_at",
      :joins => "join core_unsubscribeaction on core_action.id = core_unsubscribeaction.action_ptr_id",
      :joins => "join core_user on core_user.id = core_action.user_id",
      :conditions => ['core_action.created_at > ?', last_updated],
      :order => "core_action.created_at DESC")    
    
    @core_actions.map { |x| UnsubscribeRequest.new(x["email"], x["created_at"]) }
  end
end