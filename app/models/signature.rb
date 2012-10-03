class Signature < ActiveRecord::Base
  belongs_to :petition
  belongs_to :member
  belongs_to :referer, :class_name => 'Member', :foreign_key => 'referer_id'
  has_one :sent_email
 
  attr_accessible :email, :first_name, :last_name
  attr_accessible :reference_type, :referer, :referring_url
  attr_accessible :http_referer, :browser_name
 
  validates_presence_of :first_name, :last_name
  validates :email, :presence => true, :email => true
 
  before_save :truncate_user_agent
  after_save :geolocate
  before_destroy { |record| record.sent_email.destroy if record.sent_email }

  module ReferenceType
    FACEBOOK_LIKE = 'facebook_like'
    FACEBOOK_SHARE = 'facebook_share'
    FACEBOOK_POPUP = 'facebook_popup'
    FACEBOOK_WALL = 'facebook_wall'
    FACEBOOK_REQUEST = 'facebook_request'
    FACEBOOK_AUTOFILL_REQUEST = 'facebook_autofill_request'
    FACEBOOK_RECOMMENDATION = 'facebook_recommendation'
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
    ReferenceType::FACEBOOK_RECOMMENDATION,
    nil ]

  validates :reference_type, :inclusion => {
    :in => REFERENCE_TYPES, 
    :message => "%{value} is not a valid reference_type"
  }


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
  
  def fetch_location ip
    def ip2bigint ip
      # > ip2bigint '161.132.13.1'
      # => 2709785857
      a, b, c, d = ip.split('.').map(&:to_i)
      return a*256**3 + b*256**2 + c*256 + d
    end
    
    c = ActiveRecord::Base.connection    
    if c.table_exists? 'ip_locations'
      q1 = c.quote(ip2bigint(ip))
      result = c.execute "SELECT * FROM ip_locations WHERE box(point(ip_from,ip_from),point(ip_to,ip_to)) @> box(point (#{q1},#{q1}), point(#{q1},#{q1}))"
      out = OpenStruct.new(result.first)
      out.state = out.region
      return out
    else
      return Geocoder.search(ip).first
    end
  end

  def geolocate
    return unless place = fetch_location(ip_address)
    self.city = place.city
    self.metrocode = place.metrocode
    self.state = place.state
    self.state_code = place.state_code
    self.country_code = place.country_code
    self.member.country_code = place.country_code
    self.member.state_code = place.state_code
  end
end
