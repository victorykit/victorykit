require "spec_helper"

describe ScheduledEmail do
  describe "new_petition" do
    let(:member){ create(:member)}
    let(:petition){ create(:petition)}
    it "logs the email" do
      ScheduledEmail.new_petition(petition, member)
      SentEmail.find_by_member_id(member).petition.should eq petition
    end
  end
  describe "sending an email" do
    let(:member){ create(:member)}
    let(:petition){ create(:petition)}
    let!(:mail){ ScheduledEmail.new_petition(petition, member)}
    let(:sent_email){SentEmail.find_by_member_id(member)}
    it "includes the petition title in sthe subject" do
      mail.subject.should match /#{petition.title}/
    end
    
    it "uses the member's email address" do
      mail.to.should eq [member.email]
    end
        
    it "includes the email hash in the body" do
      email_hash = Hasher.generate(sent_email.id)
      mail.body.encoded.should include(email_hash)
    end
  end
end
