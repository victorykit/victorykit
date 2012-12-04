describe PetitionImageDownloader do
  it "downloads file and uploads to S3" do
    image = create(:petition_image, :url => 'http://foo.com/bar.jpg')

    PetitionImageDownloader.should_receive(:open).with(image.url).and_yield('file object')

    s3_object_mock = mock(AWS::S3::S3Object)
    s3_object_mock.should_receive(:write).with('file object').and_return('new s3 object')
    AWS::S3.stub_chain(:new, :buckets, :[], :objects, :[]).and_return(s3_object_mock)

    PetitionImageDownloader.download(image).should == 'new s3 object'
  end
end