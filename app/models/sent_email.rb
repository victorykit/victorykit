class SentEmail < ActiveRecord::Base
  attr_accessible :email, :member, :petition, :opened_at, :clicked_at
  belongs_to :petition
  belongs_to :member
end
