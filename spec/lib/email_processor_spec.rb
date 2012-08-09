require 'spec_helper'

describe EmailProcessor do
  let!(:sent_email) {create :sent_email}
  let!(:member) {create :member, email: sent_email.email}

  it "should create a record in bounced_emails table" do
    EmailProcessor.handle_exceptional_email("email_content", "bounce+#{sent_email.hash}@appmail.watchdog.net", "bounced")
    bounced_mail_records = BouncedEmail.find(:all)
    bounced_mail_records.size.should == 1
    bounced_mail_records[0].raw_content.should == "email_content"
    bounced_mail_records[0].sent_email_id.should == sent_email.id
  end

  it "should create a record in unsubscribes table if we have a member with such email" do
    EmailProcessor.handle_exceptional_email("email_content", "unsubscribe+#{sent_email.hash}@appmail.watchdog.net", "unsubscribe")
    unsubscribe_records = Unsubscribe.find(:all)
    unsubscribe_records.size.should == 1
    unsubscribe_records[0].email.should == sent_email.email
    unsubscribe_records[0].cause.should == 'unsubscribe'
    unsubscribe_records[0].member_id.should == member.id
  end
end