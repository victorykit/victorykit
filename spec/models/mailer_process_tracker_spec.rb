describe MailerProcessTracker do
  
  context '.create' do
    before do
      MailerProcessTracker.delete_all
      MailerProcessTracker.create
    end

    it "should create an entry if no mailer process tracker exists" do
      MailerProcessTracker.count.should == 1
      MailerProcessTracker.first.is_locked.should be_false
    end

    it "should not create a  new entry if there is a mailer process tracker already" do
      MailerProcessTracker.create
      MailerProcessTracker.count.should == 1
    end
  end
  
  it "should get the only tracker entry if one exists" do
    MailerProcessTracker.delete_all
    first = MailerProcessTracker.create

    MailerProcessTracker.should_receive(:first).and_return first
    MailerProcessTracker.in_transaction {}
  end

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

  context "lock has already been taken and not deadlocked" do
    
    before do 
      record = MailerProcessTracker.new(:is_locked => true)
      record.save!
      MailerProcessTracker.stub!(:put_to_sleep)
    end 

    it 'aborts if not deadlocked in the second check' do
      MailerProcessTracker.in_transaction do
        raise "should not have got here!"
      end
    end

    it 'unlocks if deadlocked in the second check' do
      MailerProcessTracker.any_instance.stub(:deadlocked?).and_return(false, true)
      MailerProcessTracker.in_transaction {}
      MailerProcessTracker.first.is_locked?.should be_false
    end
  end

  context 'when it is deadlock' do

    subject { MailerProcessTracker.new is_locked: true }

    it 'releases the lock in the first check' do
      first = MailerProcessTracker.create
      MailerProcessTracker.should_receive(:first).and_return first
      MailerProcessTracker.any_instance.stub(:deadlocked?).and_return(true, false)
      MailerProcessTracker.stub(:put_to_sleep)
      MailerProcessTracker.in_transaction {}
      first.is_locked.should be_false
    end

  end

  describe '#deadlocked?' do

    subject { MailerProcessTracker.new is_locked: true }

    it 'should return true when locked for more than 4 minutes' do  
      subject.updated_at = (5).minutes.ago
      subject.should be_deadlocked
    end

    it 'should be false when locked for less than 4 minutes' do
      subject.should_not be_deadlocked
    end

  end

  describe '.in_transaction' do
    subject { MailerProcessTracker }

    context 'when the block throws an error' do
      let(:logger) { mock }

      before do
        logger.stub(:error)
        Rails.stub(:logger).and_return logger
        subject.stub(:update_mailer_process)
      end

      it 'should log it' do
        logger.should_receive(:error) # improve with args
        subject.in_transaction { Error.new }
      end

      it 'should ensure mail process is updated' do
        subject.should_receive(:update_mailer_process).twice
        subject.in_transaction { Error.new }
      end
    end
  end

  describe '.update' do
    subject { MailerProcessTracker }
    let(:first) { mock }
    
    before { subject.stub(:first).and_return first }

    it 'should touch first' do
      first.should_receive :touch
      subject.update
    end
  end

  describe '.put_to_sleep' do
    subject { MailerProcessTracker }
    let(:tracker) { stub }

    before { tracker.stub(:updated_at).and_return 1.minutes.ago }

    it 'should take a nap' do
      subject.should_receive :nap
      subject.put_to_sleep tracker
    end
  end
end