class Unsubscribe < ActiveRecord::Base
  attr_accessible :email, :cause, :member
  belongs_to :member
  belongs_to :sent_email
  validates_presence_of :email
  
  scope :between, ->(from, to) { where(:created_at => from..to) }
  delegate :full_name, to: :member

  CSV_COLUMNS = [:email, :full_name]

  def self.unsubscribe_member(member)
    Unsubscribe.create(email: member.email, cause: 'unsubscribed', member: member)
  end

  def csv_header
    CSV_COLUMNS.map { |c| c.to_s.titleize }
  end

  def csv_values
    CSV_COLUMNS.map { |c| self.send(c) }
  end
end
