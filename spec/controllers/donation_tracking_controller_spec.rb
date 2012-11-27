describe DonationTrackingController do

  describe '#create' do
    let(:referral_code) { build :referral_code }
    let(:petition) { create(:petition) }
    let(:member) { create(:member) }
    let(:signature) { create(:signature, member: member) }

    shared_examples 'tracking petition and referral' do
      its(:referral_code_id) { should == referral_code.id }
      its(:petition) { should == petition }
    end

    context 'before signing' do
      before do
        post(:create, { 
          referral_code: referral_code.code, 
          petition_id: petition.id 
        })
      end
      
      subject { DonationClick.last }
      
      it_behaves_like 'tracking petition and referral'
      its(:member) { should be_nil }
    end

    context 'after signing' do
      before do
        post(:create, { 
          referral_code: referral_code.code,
          petition_id: petition.id,
          signature_id: signature.id 
        })
      end

      subject { DonationClick.last }
      
      it_behaves_like 'tracking petition and referral'
      its(:member) { should == signature.member }
    end
  end

end
