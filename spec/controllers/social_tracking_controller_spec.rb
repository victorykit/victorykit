require 'spec_helper'

describe SocialTrackingController do
  describe 'GET new' do
    it 'records a like on a petition' do
      petition = create(:petition)
      
      get(:new, {petition_id: petition.id, facebook_action: 'like'})
      like = Like.last
      like.petition.should == petition
      like.member.should be_nil
    end
    it 'records a like by a member on a petition' do
      petition = create(:petition)
      signature = create(:signature)

      get(:new, {petition_id: petition.id, signature_id: signature.id, facebook_action: 'like'})
      like = Like.last
      like.petition.should == petition
      like.member.should == signature.member
    end

    it 'records a share by a member on a petition' do
      petition = create(:petition)
      signature = create(:signature)

      get(:new, {petition_id: petition.id, signature_id: signature.id, facebook_action: 'share'})
      share = Share.last
      share.petition.should == petition
      share.action_id.should be_nil
      share.member.should == signature.member
    end

    it 'records share link popup opening by a member after signature' do
      petition = create(:petition)
      signature = create(:signature)

      get(:new, {petition_id: petition.id, signature_id: signature.id, facebook_action: 'popup'})
      popup = Popup.last
      popup.petition.should == petition
      popup.member.should == signature.member
    end
  end
end
