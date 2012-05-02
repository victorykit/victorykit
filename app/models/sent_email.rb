class SentEmail < ActiveRecord::Base
  attr_accessible :email, :member, :petition
  belongs_to :petition
  belongs_to :member
end
