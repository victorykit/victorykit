class Unsubscribe < ActiveRecord::Base
  attr_accessible :email, :cause, :member
  belongs_to :member
  belongs_to :sent_email
  validates_presence_of :email
  
  scope :between, ->(from, to) { where(:created_at => from..to) }

  def self.unsubscribe_member(member)
    Unsubscribe.create(email: member.email, cause: 'unsubscribed', member: member)
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << %w{ Email Name }
      all.each do |u|
        csv << [u.member.email, u.member.full_name]
      end
    end
  end
end
