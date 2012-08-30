class Signature < ActiveRecord::Base
  attr_accessible :email, :first_name, :last_name, :reference_type, :referer, :referring_url, :browser_name
  belongs_to :petition
  belongs_to :member
  belongs_to :referer, :class_name => 'Member', :foreign_key => 'referer_id'
  has_one :sent_email
  validates_presence_of :first_name, :last_name
  validates :email, :presence => true, :email => true
  before_destroy { |record| record.sent_email.destroy if record.sent_email }

  module ReferenceType
    FACEBOOK_LIKE = 'facebook_like'
    FACEBOOK_SHARE = 'facebook_share'
    FACEBOOK_POPUP = 'facebook_popup'
    FACEBOOK_WALL = 'facebook_wall'
    FACEBOOK_REQUEST = 'facebook_request'
    FACEBOOK_AUTOFILL_REQUEST = 'facebook_autofill_request'
    TWITTER = 'twitter'
    EMAIL = 'email'
    SHARED_LINK = 'shared_link'
    FORWARDED_NOTIFICATION = 'forwarded_notification'
  end

  REFERENCE_TYPES = [ 
    ReferenceType::TWITTER, 
    ReferenceType::EMAIL, 
    ReferenceType::FORWARDED_NOTIFICATION, 
    ReferenceType::SHARED_LINK,
    ReferenceType::FACEBOOK_LIKE, 
    ReferenceType::FACEBOOK_SHARE, 
    ReferenceType::FACEBOOK_POPUP, 
    ReferenceType::FACEBOOK_WALL, 
    ReferenceType::FACEBOOK_REQUEST,
    ReferenceType::FACEBOOK_AUTOFILL_REQUEST,
    nil ]

  validates :reference_type, :inclusion => {
    :in => REFERENCE_TYPES, 
    :message => "%{value} is not a valid reference_type"
  }

  before_save :truncate_user_agent

  def full_name
    [self.first_name,self.last_name].join " "
  end

  def truncate_user_agent
    return self.user_agent = self.user_agent[0..254] if self.user_agent
    self.user_agent = 'not a browser'
    self.browser_name = 'not a browser'
  end

  def prepopulate(member)
    self.tap do |s|
      s.first_name = member.try(:first_name)
      s.last_name = member.try(:last_name)
      s.email = member.try(:email)
    end
  end

end
