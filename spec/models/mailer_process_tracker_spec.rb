require 'spec_helper'

describe MailerProcessTracker do
  it "takes a lock on the tracking record" do
    record = MailerProcessTracker.new
    record.save!

    MailerProcessTracker.in_transaction do
      MailerProcessTracker.first.is_locked.should be_true
    end
  end
  it "releases the lock" do
    record = MailerProcessTracker.new
    record.save!

    MailerProcessTracker.in_transaction {}
    
    MailerProcessTracker.first.is_locked.should be_false
  end
  it "aborts if no lock record is available" do
    MailerProcessTracker.in_transaction do
      raise "should not have got here!"
    end
  end
  it "aborts if lock has already been taken" do
    record = MailerProcessTracker.new(:is_locked => true)
    record.save!
    
    MailerProcessTracker.in_transaction do
      raise "should not have got here!"
    end
  end
end