class EmailExperiment < ActiveRecord::Base
  attr_accessible :choice, :goal, :key, :sent_email_id
  belongs_to :sent_email
end
