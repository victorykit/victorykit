class Petition < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper
  include HtmlToPlainText

  attr_accessible :description, :title, :petition_titles_attributes, :petition_images_attributes, :petition_descriptions_attributes, :petition_summaries_attributes
  attr_accessible :description, :title, :petition_titles_attributes, :petition_images_attributes, :petition_descriptions_attributes, :petition_summaries_attributes, :to_send, :location, :as => :admin
  has_many :signatures
  has_many :sent_emails
  has_many :petition_titles, :dependent => :destroy
  has_many :petition_images, :dependent => :destroy
  has_many :petition_descriptions, :dependent => :destroy
  has_many :petition_summaries, :dependent => :destroy
  has_many :referral_codes
  belongs_to :owner, class_name:  "User"
  validates_presence_of :title, :description, :owner_id
  validates_with PetitionTitlesValidator
  before_validation :strip_whitespace
  accepts_nested_attributes_for :petition_titles, :reject_if => lambda { |a| a[:title].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :petition_images, :reject_if => lambda { |a| a[:url].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :petition_descriptions, :reject_if => lambda { |a| a[:facebook_description].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :petition_summaries, :reject_if => lambda { |a| a[:short_summary].blank? }, :allow_destroy => true

  def has_edit_permissions(current_user)
    return false if current_user.nil?
    owner.id == current_user.id || current_user.is_admin || current_user.is_super_user
  end
  
  def self.emailable_petition_ids
    select('id').where(to_send: true).map(&:id)
  end

  def self.find_interesting_petitions_for(member)
    signed = Signature.where(member_id: member).select(:petition_id).map(&:petition_id)
    sent = SentEmail.where(member_id: member).select(:petition_id).map(&:petition_id)
    select([:location, :id]).where(id: (emailable_petition_ids - signed - sent)).select { |p| p.cover? member }
  end

  def strip_whitespace
    self.title.strip! unless self.title.nil?
  end

  def experiments
    @experiments ||= PetitionExperiments.new(self)
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

  def default_description_for_sharing
    result = strip_tags(description_lsub)
    result = result.gsub("'","&apos;") || result
    result.gsub("\"","&quot;") || result
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
  
  def sigcount
    Rails.cache.fetch('signature_count_' + id.to_s) { signatures.count }
  end

  private

  def location_patterns
    return [/.*/] if (type = location_type) == 'all' 
    details = ['\w\w'] if (details = location_details.split(',')).empty?
    details.map { |d| Regexp.new("^#{type}/#{d}$") }
  end
end
