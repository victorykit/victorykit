describe UserFeedbackMailer do

  before { AppSettings['site.feedback_email'] = "feedback@example.com" }
  let(:feedback) {create :user_feedback}
  let(:mail) {UserFeedbackMailer.new_message(feedback)}

  it "puts the user's name in the from header" do
    mail.header[:from].to_s.should include(feedback.name)
  end

  it "sends feedback to aaron" do
    mail.header[:to].to_s.should == "feedback@example.com"
  end

  it "should include the user's email in the subject" do
    mail.header[:subject].to_s.should include(feedback.email)
  end

  it "should say anon in the subject if the user left no email or name" do
    feedback = create(:user_feedback, name: nil, email: nil)
    mail = UserFeedbackMailer.new_message(feedback)
    mail.header[:subject].to_s.should include('anon')
  end
end
