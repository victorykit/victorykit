describe DonationTrackingController do

  describe '#create' do
    let(:petition) { create(:petition) }
    let(:signature) { create(:signature, :member => create(:member)) }
    let(:referral_code) { create(:referral_code) }

    context 'all required params provided' do
      before do
        post(:create, {
          :petition_id => petition.id,
          :signature_id => signature.id,
          :referral_code => referral_code.code
        })
      end
      it { should respond_with 200 }
    end

    context 'no petition_id' do
      before do
        post(:create, {
          :signature_id => signature.id,
          :referral_code => referral_code
        })
      end
      it { should respond_with 500 }
    end
    
    context 'no signature_id' do
      before do
        post(:create, {
          :petition_id => petition.id,
          :referral_code => referral_code
        })
      end
      it { should respond_with 500 }
    end

    context 'no referral_code' do
      before do
        post(:create, {
          :signature_id => signature.id,
          :petition_id => petition.id
        })
      end
      it { should respond_with 500 }
    end
  end

end
