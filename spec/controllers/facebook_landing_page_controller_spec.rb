require 'spec_helper'

describe FacebookLandingPageController do
	describe "GET new" do
		it "should redirect to home page if there is no facebook request" do
	      get(:new, {request_ids: '1234'})
	      should redirect_to root_path
	    end
    	it "should populate a facebook request with petition and member" do
	      petition = create(:petition)
	      member = create(:member)
	      facebook_request = create(:facebook_request, petition: petition, member: member)
	      get(:new, {request_ids: '1234'})

	      facebook_request.should_not be_nil
	      facebook_request.petition.should == petition
	      facebook_request.member.should == member
	    end
	    it "should redirect a petition page when there is a facebook request" do
	      petition = create(:petition)
	      member = create(:member)
	      facebook_request = create(:facebook_request, petition: petition, member: member, action_id: '1234')
	      get(:new, {request_ids: '1234'})

	      should redirect_to petition_url(petition, d: MemberHasher.generate(member.id))
	    end
	end
end
