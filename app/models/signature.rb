class Signature < ActiveRecord::Base
  attr_accessible :email, :name
  belongs_to :petition
end
