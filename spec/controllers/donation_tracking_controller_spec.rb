describe DonationTrackingController do

  describe '#create' do
    let(:petition_id) { create(:petition).id }
    let(:signature_id) { create(:signature, :member => create(:member)).id }
    let(:referral_code) { create(:referral_code).code }
    
    let(:params) {{
      :petition_id => petition_id,
      :signature_id => signature_id,
      :referral_code => referral_code
    }}

    before { post(:create, params) }

    context 'all required params provided' do
      it { should respond_with 200 }
    end

    [:petition_id, :signature_id, :referral_code].each do |param|
      context "missing #{param}" do
        let(param) { nil }
        it { should respond_with 500 }
      end
    end

  end

end
