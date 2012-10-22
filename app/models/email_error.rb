class EmailError < ActiveRecord::Base

  belongs_to :member
  attr_accessible :member, :email, :error

end
