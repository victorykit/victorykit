class BouncedEmail < ActiveRecord::Base
  attr_accessible :raw_content, :sent_email
  belongs_to :sent_email
end