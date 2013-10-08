class PetitionImage < ActiveRecord::Base
  attr_accessible :url
  attr_accessible :url, :as => :admin
  belongs_to :petition

  before_validation :strip_whitespace

  private

  def strip_whitespace
    self.url.strip! unless self.url.nil?
  end

  public

  def s3_object_key
    hash = Digest::MD5.hexdigest("#{url}")
    extension = url.split('.').last
    [hash, extension].join('.')
  end

  def public_url
    if stored?
      s3 = AWS::S3.new
      s3_object = s3.buckets[Settings.aws.petition_images_bucket].objects[s3_object_key]
      s3_object.public_url.to_s
    else
      url
    end
  end
end
