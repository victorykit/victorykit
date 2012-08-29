describe Signature do
  subject { build :signature }

  context 'validating' do
    it { should validate_presence_of :email }
    it { should validate_presence_of :first_name }
    it { should validate_presence_of :last_name }
    
    it_behaves_like 'email validator'

    context 'reference types' do      
      before { subject.reference_type = type }

      ['facebook_like', 'facebook_popup', 
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
end
