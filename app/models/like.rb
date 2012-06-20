class Like < ActiveRecord::Base
  belongs_to :member
  belongs_to :petition
  # attr_accessible :title, :body
end
