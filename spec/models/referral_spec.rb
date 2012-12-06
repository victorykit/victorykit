describe Referral do
  let(:rc) { build :referral }
  subject { rc }

  its(:code) { should_not be_blank }
  its(:session) { subject.to_hash.should eq(:session_id => rc.code) }

  describe "#spin!" do
    let(:choice) { subject.spin! "test name", :goal, [:thing1, :thing2] }
    let(:data) { subject.data_for_options("test name", [:thing1, :thing2]) }
    before { choice }

    its(:new_record?) { should_not be_true }
    its(:session) { subject.to_hash.should include("test name" => choice) }
    its(:social_media_trials) { should have(1).element }

    specify { data[choice].should == [1, 0] }

    describe "#win!" do
      before { subject.win! :goal }
      specify { data[choice].should == [1, 1] }
    end
  end

  context "with a member" do
    let(:member) { create(:member) }
    subject { Referral.new member: member }
    its(:code) { should_not be_nil }

    context "with petition images" do
      let(:petition) { create(:petition, petition_images: [petition_image]) }
      subject { Referral.new member: member, petition: petition }

      context "not stored" do
        let(:petition_image) { create(:petition_image, stored: false) }
        its(:image) { should eq petition_image.public_url }
      end

      context "stored" do
        let(:petition_image) { create(:petition_image, stored: true) }
        its(:image) { should eq petition_image.public_url }
      end
    end
  end
end
