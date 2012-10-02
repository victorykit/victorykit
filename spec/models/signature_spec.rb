describe Signature do
  subject { build :signature }

  context 'validating' do
    it { should validate_presence_of :email }
    it { should validate_presence_of :first_name }
    it { should validate_presence_of :last_name }
    
    it_behaves_like 'email validator'

    context 'reference types' do      
      before { subject.reference_type = type }

      ['facebook_like', 'facebook_popup', 'facebook_recommendation',
       'facebook_wall', 'email', 'twitter'].each do |type|
        context "when #{type}" do
          let(:type) { type }
          it { should be_valid }
        end
      end
      
      context 'when unknown' do
        let(:type) { 'unknown' }
        it { should_not be_valid }
      end
    end
  end

  describe '#full_name' do
    specify { subject.full_name.should include subject.first_name }
    specify { subject.full_name.should include subject.last_name }
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


  describe '#destroy' do
    let(:sent_email) { build :sent_email }

    before { subject.sent_email = sent_email }

    it 'should remove its sent email before' do
      sent_email.should_receive :destroy
      subject.destroy
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
      Geocoder.stub(:search).with(ip).and_return [place]
      subject.ip_address = ip
      subject.geolocate
    end
    
    its(:city) { should eq 'Independence' }
    its(:metrocode) { should eq '616' }
    its(:state) { should eq 'Missouri' }
    its(:state_code) { should eq 'MO' }
    its(:country_code) { should eq 'US' }
  end

  context 'after being saved' do
    it 'should geolocate itself' do
      subject.should_receive :geolocate
      subject.run_callbacks :save
    end
  end

  context "analytics" do
    it "should increment signature count on create" do
      expect { create(:signature) }.to change{ $statsd.value_of("signatures") }.from(0).to(1)
    end

    it "should increment members joined if a new member was created" do
      expect { create(:signature, created_member: true) }.to change{ $statsd.value_of("members_joined") }.from(0).to(1)
    end

    it "should not increment members joined if a new member was not created" do
      expect { create(:signature, created_member: false) }.to_not change{ $statsd.value_of("members_joined") }
    end
  end
end
