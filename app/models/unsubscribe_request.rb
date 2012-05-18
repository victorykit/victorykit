class UnsubscribeRequest
  attr_accessor :email, :created_at

  def initialize(email, created_at)
    @email = email
    @created_at = created_at
  end
  
  def unsubscribe_member
    member = Member.find_by_email(email)
    Unsubscribe.unsubscribe_member(member) unless member.nil?
  end
end