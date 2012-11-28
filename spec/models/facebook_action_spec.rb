describe FacebookAction do
  
  describe "analytics" do
    it "should increment facebook_action count on create" do
      expect { create(:facebook_request) }.to change{ $statsd.value_of("facebook_actions.count") }.from(0).to(1)
    end
  end

end
