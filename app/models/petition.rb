class Petition < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper
  include HtmlToPlainText

  attr_accessible :description, :title, :facebook_description, :petition_titles_attributes, :petition_images_attributes, :short_summary
  attr_accessible :description, :title, :facebook_description, :petition_titles_attributes, :petition_images_attributes, :short_summary, :to_send, :location, :as => :admin
  has_many :signatures
  has_many :sent_emails
  has_many :petition_titles, :dependent => :destroy
  has_many :petition_images, :dependent => :destroy
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
    Petition.find_all_by_to_send(true) -
      Signature.find_all_by_member_id(member).map{|s| s.petition} -
      SentEmail.find_all_by_member_id(member).map{|e| e.petition}
  end

  def strip_whitespace
    self.title.strip! unless self.title.nil?
  end

  def experiments
    @experiments ||= PetitionExperiments.new(self)
  end

  def facebook_description_for_sharing
    description_for_sharing = facebook_description.present? ? facebook_description : description
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
    bsub = "<br><br>#{sub}<br><br>".gsub /(<br>){4}/, '<br><br>'
    description.gsub /(<br>){2}LINK(<br>){2}/, bsub
  end

end