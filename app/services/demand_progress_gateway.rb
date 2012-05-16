class DemandProgressGateway < ActiveRecord::Base
  self.abstract_class = true
  
  establish_connection :development
end

class UnsubscribeRequest
  attr_accessor :email, :created_at

  def initialize(email, created_at)
    @email = email
    @created_at = created_at
  end
end
