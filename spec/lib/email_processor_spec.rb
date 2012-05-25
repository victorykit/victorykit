require 'spec_helper'

describe EmailProcessor do
  before do
    create :sent_email, :id => 1, :email => 'user@domain.com'
    create :member, :id => 3, :email => 'user@domain.com'
  end

  it "should create a record in bounced_emails table" do
    puts Settings
    EmailProcessor.handle_exceptional_email("email_content", "bounce+1.pODiZ5@appmail.watchdog.net", "bounced")
    bounced_mail_records = BouncedEmail.find(:all)
    bounced_mail_records.size.should == 1
    bounced_mail_records[0].raw_content.should == "email_content"
    bounced_mail_records[0].sent_email_id.should == 1
  end

  it "should create a record in unsubscribes table if we have a member with such email" do
    EmailProcessor.handle_exceptional_email("email_content", "unsubscribe+1.pODiZ5@appmail.watchdog.net", "unsubscribe")
    unsubscribe_records = Unsubscribe.find(:all)
    unsubscribe_records.size.should == 1
    unsubscribe_records[0].email.should == 'user@domain.com'
    unsubscribe_records[0].cause.should == 'unsubscribe'
    unsubscribe_records[0].member_id.should == 3

  end

end
