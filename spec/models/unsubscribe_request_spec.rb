describe UnsubscribeRequest do
  describe "unsubscribe_members" do
    it "should unsubscribe members in the request" do
      @unsubscribe_request = UnsubscribeRequest.new("blah", Time.now)
      Member.any_instance.stub(:find_by_email).and_return(Member.new)
      Unsubscribe.any_instance.stub(:unsubscribe_member).with(Member.new)
      @unsubscribe_request.unsubscribe_member
    end
  end
end