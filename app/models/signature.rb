class Signature < ActiveRecord::Base
  belongs_to :petition
  belongs_to :member
  belongs_to :referer, :class_name => 'Member', :foreign_key => 'referer_id'
  has_one :sent_email

  attr_accessible :email, :first_name, :last_name, :member
  attr_accessible :reference_type, :referer, :referring_url
  attr_accessible :http_referer, :browser_name

  validates_presence_of :first_name, :last_name, :member_id
  validates :email, :presence => true, :email => true

  after_create :ensure_membership_updated
  before_save :truncate_user_agent
  before_save :geolocate
  after_save :clear_cache
  before_destroy { |record| record.sent_email.destroy if record.sent_email }

  TEST_MEMBER = 79459 # (aaron)

  def self.created
    where(created_member: true).where("referer_id != ? or referer_id is null", TEST_MEMBER)
  end

  module ReferenceType
    FACEBOOK_LIKE = 'facebook_like'
    FACEBOOK_SHARE = 'facebook_share'
    FACEBOOK_SHARE_FROM_EMAIL = 'facebook_share_from_email'
    FACEBOOK_POPUP = 'facebook_popup'
    FACEBOOK_DIALOG = 'facebook_dialog'
    FACEBOOK_REQUEST = 'facebook_request'
    FACEBOOK_AUTOFILL_REQUEST = 'facebook_autofill_request'
    FACEBOOK_RECOMMENDATION = 'facebook_recommendation'
    TWITTER = 'twitter'
    EMAIL = 'email'
    SHARED_LINK = 'shared_link'
    SHARED_LINK_FROM_MODAL = 'shared_link_from_modal'
    FORWARDED_NOTIFICATION = 'forwarded_notification'
  end

  REFERENCE_TYPES = [
    ReferenceType::TWITTER,
    ReferenceType::EMAIL,
    ReferenceType::FORWARDED_NOTIFICATION,
    ReferenceType::SHARED_LINK,
    ReferenceType::SHARED_LINK_FROM_MODAL,
    ReferenceType::FACEBOOK_LIKE,
    ReferenceType::FACEBOOK_SHARE,
    ReferenceType::FACEBOOK_SHARE_FROM_EMAIL,
    ReferenceType::FACEBOOK_POPUP,
    ReferenceType::FACEBOOK_DIALOG,
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

  def geolocate
    return unless place = fetch_location
    self.city = place.city
    self.metrocode = place.metrocode
    self.state = place.state
    self.state_code = place.state_code
    self.country_code = place.country_code
    self.member.country_code = place.country_code
    self.member.state_code = place.state_code
    self.member.save
  end

  # could the next two methods take part in a separated class?

  def fetch_location
    c = Signature.connection
    return Geocoder.search(ip_address).first unless c.table_exists? 'ip_locations'
    ip = c.quote ip2bigint
    q = <<-SQL
      SELECT *
      FROM ip_locations
      WHERE box(
        point(ip_from, ip_from),
        point(ip_to, ip_to)
      ) @> box(
        point(#{ip}, #{ip}),
        point(#{ip}, #{ip})
      )
    SQL
    OpenStruct.new(c.execute(q).first).tap{|o|o.state=o.region}
  end

  def ip2bigint
    ip_address.split('.').map(&:to_i).each_with_index.map{|e,i|e*256**(3-i)}.reduce(&:+)
  end

  def track_referrals(params = {})
    self.attributes = SignatureReferral.new(self.petition, self, params).referral
  end

  def clear_cache
    Rails.cache.delete('signature_count_' + self.petition_id.to_s)
  end

  def referral
    Referral.where(:member_id => referer_id, :petition_id => petition_id).first if referer_id
  end

  private

  def ensure_membership_updated
    member.touch_last_signed_at!
  end

end
