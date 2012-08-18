require 'spec_helper'

describe SocialTrackingController do

  before(:each) do
    stub_bandit controller
  end

  describe 'GET new' do

    let(:petition) { create(:petition) }
    let(:signature) { create(:signature) }

    context 'when someone likes a petition' do
      
      context 'before signing' do
        before { get :new, { petition_id: petition.id, facebook_action: 'like' } }
        
        subject { Like.last }
        
        its(:petition) { should == petition }
        its(:member) { should be_nil }
      end

      context 'after signing' do
        before { get :new, { petition_id: petition.id, signature_id: signature.id, facebook_action: 'like' } }

        subject { Like.last }
        
        its(:petition) { should == petition }
        its(:member) { should == signature.member }
      end
    end

    context 'when someone shares a petition' do
      before { get :new, { petition_id: petition.id, signature_id: signature.id, facebook_action: 'share' } }

      subject { Share.last }

      its(:petition) { should == petition }
      its(:action_id) { should be_nil }
      its(:member) { should == signature.member }
    end

    context 'when someone opens a share link popup' do
      before { get :new, { petition_id: petition.id, signature_id: signature.id, facebook_action: 'popup' } }
      
      subject { Popup.last }
      
      its(:petition) { should == petition }
      its(:member) { should == signature.member }
    end

    context 'when someone shares the petition with her friends' do
      before { get :new, { petition_id: petition.id, signature_id: signature.id, facebook_action: 'wall' } }

      subject { FacebookWall.last }
      
      its(:petition) { should == petition }
      its(:member) { should == signature.member }      
    end
  end
end
