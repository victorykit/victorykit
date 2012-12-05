describe PetitionImage do
  describe "s3 object key" do
    it "is a hash of the url with a file extension" do
      image = build(:petition_image, :url => 'foo.jpg')
      image.s3_object_key.should == Digest::MD5.hexdigest("foo.jpg") + ".jpg"
    end
  end

  describe "public url" do
    context "when image has been stored" do
      before { AWS::S3.stub_chain(:new, :buckets, :[], :objects, :[], :public_url).and_return('aws url') }
      subject(:image) { build(:petition_image, url: 'foo.jpg', stored: true) }
      its(:public_url) { should == 'aws url' }
    end

    context "when image has not been stored" do
      subject(:image) { build(:petition_image, url: 'foo.jpg', stored: false) }
      its(:public_url) { should == 'foo.jpg' }
    end
  end
end