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
    let(:email_hash){Hasher.generate(sent_email.id)}
    let(:petition_link){"http://test/petitions/#{petition.id}?n=#{email_hash}"}
    let(:unsubscribe_link){"http://test/unsubscribes/new?n=#{email_hash}"}
    
    it "includes the petition title in the subject" do
      mail.subject.should include petition.title
    end
    
    it "uses the member's email address" do
      mail.to.should match /<#{member.email}>$/
    end

    it "includes the petition link in the body" do
      mail.body.encoded.should include petition_link
    end
        
    it "includes an unsubscribe link in the body" do
      mail.body.encoded.should include unsubscribe_link
    end
    
    it "adds an unsubscribe header" do
      mail["List-Unsubscribe"].value.should eq "<#{unsubscribe_link}>"
    end
  end
end
