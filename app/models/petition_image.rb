class PetitionImage < ActiveRecord::Base
  attr_accessible :url
  attr_accessible :url, :as => :admin
  belongs_to :petition

  def s3_object_name
    hash = Digest::MD5.hexdigest("#{id} #{url}")
    extension = url.split('.').last
    [hash, extension].join('.')
  end
end
