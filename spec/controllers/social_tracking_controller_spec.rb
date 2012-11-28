describe SocialTrackingController do

  before(:each) do
    stub_bandit controller
  end

  describe 'POST create' do

    let(:petition) { create(:petition) }
    let(:member) { create(:member) }
    let(:signature) { create(:signature, member: member) }

    context 'on any facebook action' do
      context 'the users facebook id is available' do
        let(:facebook_uid) { 123 }
        before { 
          post :create, { petition_id: petition.id, signature_id: signature.id, facebook_uid: facebook_uid, facebook_action: 'like' } 
          member.reload
        }
        subject {member}
        its(:facebook_uid) {
          should == facebook_uid
        }
      end
      context 'the users facebook id is not available' do
        let(:facebook_uid) { 0 }
        before { 
          post :create, { petition_id: petition.id, signature_id: signature.id, facebook_uid: facebook_uid, facebook_action: 'like' } 
          member.reload
        }
        subject {member}
        its(:facebook_uid) {
          should be_nil
        }
      end
    end

    context 'when someone likes a petition' do
      
      context 'before signing' do
        before { post :create, { petition_id: petition.id, facebook_action: 'like' } }
        
        subject { Like.last }
        
        its(:petition) { should == petition }
        its(:member) { should be_nil }
      end

      context 'after signing' do
        before { post :create, { petition_id: petition.id, signature_id: signature.id, facebook_action: 'like' } }

        subject { Like.last }
        
        its(:petition) { should == petition }
        its(:member) { should == signature.member }
      end
    end

    context 'when someone shares a petition' do
      before { post :create, { petition_id: petition.id, signature_id: signature.id, facebook_action: 'share' } }

      subject { Share.last }

      its(:petition) { should == petition }
      its(:action_id) { should be_nil }
      its(:member) { should == signature.member }
    end

    context 'when someone opens a share link popup' do
      before { post :create, { petition_id: petition.id, signature_id: signature.id, facebook_action: 'popup' } }
      
      subject { Popup.last }
      
      its(:petition) { should == petition }
      its(:member) { should == signature.member }
    end

    context 'when someone recommends a petition to friends' do
      before { post :create, { petition_id: petition.id, signature_id: signature.id, facebook_action: 'recommend' } }
      
      subject { FacebookRecommendation.last }
      
      its(:petition) { should == petition }
      its(:member) { should == signature.member }
    end    
  end
end
