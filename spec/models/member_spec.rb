describe Member do
  describe 'instance' do
    it { should allow_mass_assignment_of :first_name }
    it { should allow_mass_assignment_of :last_name }
    it { should allow_mass_assignment_of :email }
    it { should allow_mass_assignment_of :country_code }
    it { should allow_mass_assignment_of :state_code }

    it { should validate_presence_of :first_name }
    it { should validate_presence_of :last_name }
    it { should validate_presence_of :email }

    describe '#has_signed?' do
      let(:petition) { stub(:id => 42) }
      before { subject.stub_chain(:signatures, :where).and_return [signature] }

      context 'before signing a petition' do
        let(:signature) { nil }
        it { should_not have_signed petition }
      end

      context 'after signing a petition' do
        let(:signature) { anything }
        it { should have_signed petition }
      end
    end

    describe '#to_hash' do
      let(:id) { subject.id }
      before { MemberHasher.stub(:generate).with(id).and_return 'foo' }
      specify { subject.to_hash.should eql 'foo' }
    end

    describe '#full_name' do
      subject { build :member }
      specify { subject.full_name.should include subject.first_name }
      specify { subject.full_name.should include subject.last_name }
    end

    describe '#signature_for' do
      let(:petition) { build :petition, :id => 5 }
      let(:signature) { build :signature }

      before do
        subject.signatures.stub(:where).with(petition_id:5).and_return result
      end

      context 'signed petition' do
        let(:result) { [signature] }
        specify { subject.signature_for(petition).should == signature }
      end

      context 'not signed petition' do
        let(:result) { [] }
        specify { subject.signature_for(petition).should be_nil }
      end
    end

    describe '#last_location' do
      context 'when never signed' do
        its(:last_location) { should == '' }
      end

      context 'when last signed from' do
        subject { build :member, :country_code => country, :state_code => state } 
        
        context 'us' do
          let(:country) { 'US' }
          let(:state) { 'NY' }
          its(:last_location) { should == 'us/NY' }
        end

        context 'outside us' do
          let(:country) { 'BR' }
          let(:state) { 'RS' }
          its(:last_location) { should == 'non-us/BR' }
        end

        context 'unknown' do
          let(:country) { nil }
          let(:state) { nil }
          its(:last_location) { should == '' }
        end
      end
    end
  end

  describe 'class' do
    subject { Member }
    let(:member) { build :member }

    describe '.find_by_hash' do

      context 'for a valid hash' do
        let(:id) { 42 }

        before do
          Member.stub(:where).with(:id => id).and_return [member]
          MemberHasher.stub(:validate).with('foo').and_return 42
        end  

        specify { subject.find_by_hash('foo').should eql member }
      end
      
      context 'for nil hash' do
        let(:id) { nil }

        before do
          Member.stub(:where).with(:id => id).and_return []
          MemberHasher.stub(:validate).with(nil).and_return id
        end

        specify { subject.find_by_hash(nil).should be_nil }
      end  
    end

    describe '.random_and_not_recently_contacted' do

      shared_examples 'ignoring them' do
        specify { subject.random_and_not_recently_contacted(1).should eql [] }
      end

      shared_examples 'finding them' do
        specify { subject.random_and_not_recently_contacted(1)[0].should eql member }
      end

      context 'for members who have previously signed a petition' do
        context 'and joined that way less than a week ago' do
          before { create :signature, created_member: true, created_at: 6.days.ago, member: member }
          it_behaves_like 'ignoring them'
        end

        context 'and joined that way more than a week ago' do
          before { create :signature, created_member: true, created_at: 8.days.ago, member: member }
          it_behaves_like 'finding them'
        end

        context 'and signed recently but joined more than a week ago' do
          before { create :signature, created_member: false, created_at: 6.days.ago, member: member }
          it_behaves_like 'finding them'
        end
      end

      context 'for recently contacted members' do
        before { create :sent_email, member: member }
        it_behaves_like 'ignoring them'
      end

      context 'for unsubscribed members' do
        before { create :unsubscribe, member: member }
        it_behaves_like 'ignoring them'
      end

      context 'for members contacted more than a week ago' do
        before { create :sent_email, created_at: 8.days.ago, member: member }
        
        context 'and never unsubscribed' do
          it_behaves_like 'finding them'
        end

        context 'and have unsubscribed in the past' do
          it_behaves_like 'finding them'
        end

        context 'and have unsubscribed again' do
          before do
            Subscribe.stub_chain(:group, :maximum).
              and_return(member.id => 8.days.ago)

            Unsubscribe.stub_chain(:group, :maximum).
              and_return(member.id => 3.days.ago)
          end

          it_behaves_like 'ignoring them'
        end
      end
      
    end
  end

end
