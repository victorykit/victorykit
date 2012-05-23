class SentEmail < ActiveRecord::Base
  attr_accessible :email, :member, :petition, :was_opened, :clicked_at
  belongs_to :petition
  belongs_to :member
end
