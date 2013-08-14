describe Signature do
  subject { build :signature }

  context 'validating' do
    it { should allow_mass_assignment_of :email }
    it { should allow_mass_assignment_of :first_name }
    it { should allow_mass_assignment_of :last_name }
    it { should allow_mass_assignment_of :reference_type }
    it { should allow_mass_assignment_of :referer }
    it { should allow_mass_assignment_of :referring_url }
    it { should allow_mass_assignment_of :http_referer }
    it { should allow_mass_assignment_of :browser_name }
    it { should allow_mass_assignment_of :member }

    it { should validate_presence_of :email }
    it { should validate_presence_of :first_name }
    it { should validate_presence_of :last_name }
    it { should validate_presence_of :member_id }

    it { should ensure_inclusion_of(:reference_type).in_array(Signature::REFERENCE_TYPES) }

    it_behaves_like 'email validator'
  end

  describe '#full_name' do
    before do
      subject.first_name = 'Peter'
      subject.last_name = 'Griffin'
    end
    its(:full_name) { should == 'Peter Griffin' }
  end

  context 'before save' do
    it 'should truncate user agent' do
      subject.should_receive :truncate_user_agent
      subject.run_callbacks :save
    end
  end

  describe '#truncate_user_agent' do
    before do
      subject.user_agent = agent
      subject.truncate_user_agent
    end

    context 'for a long user agent' do
      let(:agent) { '0' * 512 }
      its(:user_agent) { should have(255).characters }
    end

    context 'for no user agent' do
      let(:agent) { nil }
      its(:user_agent) { should eq 'not a browser' }
      its(:browser_name) { should eq 'not a browser' }
    end
  end

  context 'before destroy' do
    let(:sent_email) { build :sent_email }

    before { subject.sent_email = sent_email }

    it 'should remove its sent email' do
      sent_email.should_receive :destroy
      subject.run_callbacks :destroy
    end
  end

  context 'after save' do
    it 'should geolocate' do
      subject.should_receive :geolocate
      subject.run_callbacks :save
    end
  end

  context 'after create' do
    it 'should update the membership stats' do
      subject.member.should_receive :touch_last_signed_at!
      subject.run_callbacks :create
    end
  end

  describe '#geolocate' do
    let(:ip) { '24.2.3.4' }
    let(:place) { stub(
      city: 'Independence',
      metrocode: '616',
      state: 'Missouri',
      state_code: 'MO',
      country_code: 'US'
    )}

    before do
      subject.stub(:fetch_location).and_return place
      subject.ip_address = ip
      subject.member.should_receive :save
      subject.geolocate
    end

    its(:city) { should eq 'Independence' }
    its(:metrocode) { should eq '616' }
    its(:state) { should eq 'Missouri' }
    its(:state_code) { should eq 'MO' }
    its(:country_code) { should eq 'US' }

    it 'should update member location' do
      subject.member.country_code.should == 'US'
      subject.member.state_code.should == 'MO'
    end
  end

  describe '#fetch_location' do
    subject { build :signature, :ip_address => '161.132.13.1' }
    let(:db) { stub }

    before do
      Signature.stub(:connection).and_return db
      db.stub(:table_exists?).with('ip_locations').and_return available
      db.stub(:quote).and_return anything
    end

    context 'when local lookup is unavailable' do
      let(:available) { false }

      it 'should fallback to remote service' do
        Geocoder.should_receive(:search).with('161.132.13.1').and_return [anything]
        subject.fetch_location
      end
    end

    context 'when local lookup is available' do
      let(:available) { true }
      let(:data) { { :region => 'CA' } }

      it 'should fetch from db' do
        db.should_receive(:execute).and_return [data]
        subject.fetch_location
      end
    end
  end

  describe '#ip2bigint' do
    subject { build :signature, :ip_address => '161.132.13.1' }
    its(:ip2bigint) { should == 2709785857 }
  end

  context "analytics" do
    it "should increment signature count on create" do
      expect { create(:signature) }.to change{ $statsd.value_of("signatures.count") }.from(0).to(1)
    end

    it "should increment members joined if a new member was created" do
      expect { create(:signature, created_member: true) }.to change{ $statsd.value_of("members_joined.count") }.from(0).to(1)
    end

    it "should not increment members joined if a new member was not created" do
      expect { create(:signature, created_member: false) }.to_not change{ $statsd.value_of("members_joined.count") }
    end
  end
end
