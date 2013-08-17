class Petition < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper
  include HtmlToPlainText

  attr_accessible :description, :title, :petition_versions_attributes,
    :petition_titles_attributes, :petition_images_attributes,
    :petition_descriptions_attributes, :petition_summaries_attributes

  attr_accessible :description, :title, :petition_versions_attributes,
    :petition_titles_attributes, :petition_images_attributes,
    :petition_descriptions_attributes, :petition_summaries_attributes,
    :to_send, :location, :as => :admin

  has_many :petition_versions
  has_many :signatures
  has_many :sent_emails
  has_many :referrals
  has_many :petition_titles, :dependent => :destroy
  has_many :petition_images, :dependent => :destroy
  has_many :petition_summaries, :dependent => :destroy
  has_many :petition_descriptions, :dependent => :destroy
  belongs_to :owner, class_name:  "User"

  before_validation :strip_whitespace
  validates_presence_of :title, :description, :owner_id
  validates_with PetitionTitlesValidator

  accepts_nested_attributes_for :petition_titles,
    :reject_if => lambda { |a| a[:title].blank? },
    :allow_destroy => true

  accepts_nested_attributes_for :petition_images,
    :reject_if => lambda { |a| a[:url].blank? },
    :allow_destroy => true

  accepts_nested_attributes_for :petition_descriptions,
    :reject_if => lambda { |a| a[:facebook_description].blank? },
    :allow_destroy => true

  accepts_nested_attributes_for :petition_summaries,
    :reject_if => lambda { |a| a[:short_summary].blank? },
    :allow_destroy => true

  scope :not_deleted, where('deleted is not true')
  scope :recently_featured, where('to_send and featured_on > ?', 3.days.ago)

  def featured?; self.to_send; end

  def previously_not_featured; !featured?; end

  def has_edit_permissions(current_user)
    return false if current_user.nil?
    owner.id == current_user.id || current_user.is_admin || current_user.is_super_user
  end

  def self.emailable_petition_ids
    select('id').not_deleted.where(to_send: true).map(&:id)
  end

  def self.find_interesting_petitions_for(member)
    select([:location, :id]).
      where(id: (emailable_petition_ids - member.previous_petition_ids)).
      select { |p| p.cover? member }
  end

   def update_petition_version
    if petition_versions.first.present?
      petition_versions.first.update_attributes(title: title, description: description)
    else
      PetitionVersion.create(title: title, description: description, petition_id: id)
    end
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
    Rails.cache.fetch('signature_count_' + id.to_s) { signatures.count('email', :distinct => true) }
  end

  def image_urls
    petition_images.map(&:url)
  end

  def summary_texts
    petition_summaries.map(&:short_summary)
  end

  private

  def location_patterns
    return [/.*/] if (type = location_type) == 'all'
    details = ['\w\w'] if (details = location_details.split(',')).empty?
    details.map { |d| Regexp.new("^#{type}/#{d}$") }
  end
end
