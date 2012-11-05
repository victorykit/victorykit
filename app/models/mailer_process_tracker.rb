class MailerProcessTracker < ActiveRecord::Base
  attr_accessible :is_locked
  
  def self.count
    self.delete_all("updated_at < (now() - interval '5 minutes')")
    super
  end
end
