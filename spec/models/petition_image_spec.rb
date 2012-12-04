describe PetitionImage do
  describe "s3 object name" do
    it "is a hash of id and url with a file extension" do
      pi = create(:petition_image, :url => 'foo.jpg')
      pi.s3_object_name.should == Digest::MD5.hexdigest("#{pi.id} foo.jpg") + ".jpg"
    end
  end
end