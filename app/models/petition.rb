class Petition < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper
  include HtmlToPlainText

  attr_accessible :description, :title, :facebook_description, :petition_titles_attributes, :petition_images_attributes, :short_summary
  attr_accessible :description, :title, :facebook_description, :petition_titles_attributes, :petition_images_attributes, :short_summary, :to_send, :location, :as => :admin
  has_many :signatures
  has_many :sent_emails
  has_many :petition_titles, :dependent => :destroy
  has_many :petition_images, :dependent => :destroy
  has_many :referral_codes
  belongs_to :owner, class_name:  "User"
  validates_presence_of :title, :description, :owner_id
  validates_length_of :facebook_description, :maximum => 300
  validates_length_of :short_summary, :maximum => 255
  validates_with PetitionTitlesValidator
  before_validation :strip_whitespace
  accepts_nested_attributes_for :petition_titles, :reject_if => lambda { |a| a[:title].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :petition_images, :reject_if => lambda { |a| a[:url].blank? }, :allow_destroy => true

  def has_edit_permissions(current_user)
    return false if current_user.nil?
    owner.id == current_user.id || current_user.is_admin || current_user.is_super_user
  end

  def self.find_interesting_petitions_for(member)
    signed = Signature.find_all_by_member_id(member).map(&:petition)
    sent = SentEmail.find_all_by_member_id(member).map(&:petition)
    (find_all_by_to_send(true) - signed - sent).select { |p| p.cover? member }
  end

  def strip_whitespace
    self.title.strip! unless self.title.nil?
  end

  def experiments
    @experiments ||= PetitionExperiments.new(self)
  end

  def facebook_description_for_sharing
    description_for_sharing = facebook_description.present? ? facebook_description : description_lsub
    result = strip_tags(description_for_sharing)
    result = result.gsub("'","&apos;") || result
    result.gsub("\"","&quot;") || result
  end

  def plain_text_description
    convert_to_text(description_lsub)
  end

  def plain_text_title
    convert_to_text(title)
  end

  def description_lsub sub=''
    b = "<br><br>"
    bsub = "#{b}#{sub}#{b}".gsub(/#{b}#{b}/, "#{b}")
    d = description.gsub(/#{b}LINK#{b}/, bsub)

    psub = "<p>#{sub}</p>".gsub(/<p><\/p>/, "")
    d.gsub(/<p>LINK<\/p>/, psub)
  end

  def location_type
    return 'all' unless location.present?
    location.split(',').first.split('/').first
  end

  def location_details
    return '' unless location.present?
    location.scan(/\/(\w\w)/).join(',')
  end

  def cover? member
    location_patterns.find { |p| member.last_location =~ p }
  end

  private

  def location_patterns
    return [/.*/] if (type = location_type) == 'all' 
    details = ['\w\w'] if (details = location_details.split(',')).empty?
    details.map { |d| Regexp.new("^#{type}/#{d}$") }
  end
end
