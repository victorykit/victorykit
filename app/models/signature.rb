class Signature < ActiveRecord::Base
  attr_accessible :email, :name, :first_name, :last_name
  belongs_to :petition
  belongs_to :member
  validates_presence_of :name, :first_name, :last_name
  validates :email, :presence => true, :email => true

  before_save :truncate_user_agent, :first_name, :last_name

  def first_name 
    self.name.split(" ").first unless self.name.nil?
  end

  def last_name 
    self.name.split(" ").last unless self.name.nil?
  end

  def first_name=(val)
    self.name = "#{val} #{last_name}".strip
  end

  def last_name=(val)
    self.name = "#{first_name} #{val}".strip
  end

	def truncate_user_agent
	  self.user_agent = self.user_agent[0..254]
	end
end
