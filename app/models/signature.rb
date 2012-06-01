class Signature < ActiveRecord::Base
  attr_accessible :email, :name
  belongs_to :petition
  belongs_to :member
  validates_presence_of :name
  validates :email, :presence => true, :email => true

  before_save :truncate_user_agent

	def truncate_user_agent
	  self.user_agent = self.user_agent[0..254]
	end
end
