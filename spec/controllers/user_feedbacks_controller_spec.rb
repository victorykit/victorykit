describe UserFeedbacksController do
  describe "GET new" do
    it "assigns a new user feedback" do
      get :new
      assigns(:feedback).should be_a_new(UserFeedback)
    end
  end

  describe "POST feedback" do
    it "mails feedback to site admin" do
      UserFeedbackMailer.any_instance.should_receive(:new_message)
      post :create, {:user_feedback => {:email => "me@my.com", :name => "billy feedbacker", :message => "love the site!"}}
      new_user_feedback = UserFeedback.find_by_email "me@my.com"
      new_user_feedback.message.should eq "love the site!"
    end

    it "does not allow empty messages" do
      post :create, {:user_feedback => {:email => "me@my.com", :name => "billy feedbacker", :message => nil}}
      assigns(:feedback).errors.should_not be_empty
    end
  end
end
