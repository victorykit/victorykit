require 'spec_helper'

describe DonationTrackingController do

  describe 'POST create' do
    let(:rc) { build :referral_code }

    let(:referral_code) { build :referral_code }
    let(:petition) { create(:petition) }
    let(:member) { create(:member) }
    let(:signature) { create(:signature, member: member) }

    context 'when someone donates' do
      
      context 'before signing' do
        before { post :create, { referral_code: referral_code.code, petition_id: petition.id } }
        
        subject { DonationClick.last }
        
        its(:referral_code_id) { should == referral_code.id }
        its(:petition) { should == petition }
        its(:member) { should be_nil }
      end

      context 'after signing' do
        before { post :create, { referral_code: referral_code.code, petition_id: petition.id, signature_id: signature.id } }

        subject { DonationClick.last }
        
        its(:referral_code_id) { should == referral_code.id }
        its(:petition) { should == petition }
        its(:member) { should == signature.member }
      end
    end
  end
end