describe PetitionImageDownloader do

  let(:image) { create(:petition_image, :url => 'http://foo.com/bar.jpg') }
  before { PetitionImageDownloader.should_receive(:open).with(image.url).and_yield('file object') }

  it "downloads file and uploads to S3" do
    s3_object_mock = mock(AWS::S3::S3Object)
    s3_object_mock.should_receive(:write).with('file object', :acl => :public_read).and_return('new s3 object')
    AWS::S3.stub_chain(:new, :buckets, :[], :objects, :[]).and_return(s3_object_mock)

    PetitionImageDownloader.download(image).should == true
  end

  context "when file upload is successful" do
    it "marks petition image as stored" do
      AWS::S3.stub_chain(:new, :buckets, :[], :objects, :[], :write).and_return('s3 object')
      PetitionImageDownloader.download(image)
      image.should be_stored
    end
  end

  context "when file upload fails" do
    it "does not mark petition image as stored" do
      AWS::S3.stub_chain(:new, :buckets, :[], :objects, :[], :write).and_raise(AWS::S3::Errors::NoSuchBucket)
      PetitionImageDownloader.download(image).should == false
      image.should_not be_stored
    end
  end
end