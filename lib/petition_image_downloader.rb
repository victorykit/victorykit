class PetitionImageDownloader
  class << self
    def download(image)
      s3 = AWS::S3.new
      s3_object = s3.buckets[Settings.aws.petition_images_bucket].objects[image.s3_object_key]
      begin
        open(image.url) do |f|
          s3_object.write(f, :acl => :public_read)
          image.update_attribute(:stored, true)
        end
      rescue Exception => e
        image.update_attribute(:stored, false)
      end
      image.stored?
    end
  end
end