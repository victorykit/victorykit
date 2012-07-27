class Signature < ActiveRecord::Base
  attr_accessible :email, :name, :first_name, :last_name, :reference_type, :referer, :referring_url
  belongs_to :petition
  belongs_to :member
  belongs_to :referer, :class_name => 'Member', :foreign_key => 'referer_id'
  has_one :sent_email
  validates_presence_of :name, :first_name, :last_name
  validates :email, :presence => true, :email => true

  module ReferenceType
    FACEBOOK_LIKE = 'facebook_like'
    FACEBOOK_SHARE = 'facebook_share'
    FACEBOOK_POPUP = 'facebook_popup'
    TWITTER = 'twitter'
    EMAIL = 'email'
    SHARED_LINK = 'shared_link'
    FORWARDED_NOTIFICATION = 'forwarded_notification'
  end

  REFERENCE_TYPES = [ ReferenceType::FACEBOOK_LIKE, ReferenceType::FACEBOOK_SHARE, ReferenceType::FACEBOOK_POPUP, ReferenceType::TWITTER, ReferenceType::EMAIL, ReferenceType::FORWARDED_NOTIFICATION, ReferenceType::SHARED_LINK, nil ]

  validates :reference_type, :inclusion => {:in => REFERENCE_TYPES, :message => "%{value} is not a valid reference_type"}

  before_save :truncate_user_agent

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
