class PetitionImageDownloader
  class << self
    def download(image)
      s3 = AWS::S3.new
      s3_object = s3.buckets[Settings.aws.petition_images_bucket].objects[image.s3_object_name]
      open(image.url) do |f|
        s3_object.write(f)
      end
    end
  end
end