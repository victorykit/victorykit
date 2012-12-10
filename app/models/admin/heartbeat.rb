class Admin::Heartbeat

  def last_sent_email
    ScheduledEmail.last.created_at
  end

  def last_signature
    Signature.last.created_at  
  end

  def emails_sent_since date_time
    ScheduledEmail.where("created_at > ?", date_time).count
  end

  def emailable_members
    Member.count - Unsubscribe.count
  end
  
  def new_members
    Signature.where(created_member: true).count - Unsubscribe.where("cause='unsubscribed'").count
  end

  def emails_in_queue
    Resque.size("signed_petition_emails")
  end

  def emails_max_queue
    Resque.queues.max_by { |queue| Resque.size(queue) } .to_i
  end

  def workers
    Resque.info[:workers]
  end

  def status
    status = ApplicationStatus.new.tap do |s|
      s[:email] = EmailStatus.new self, true
      s[:signature] = SignatureStatus.new self, false
      s[:resque] = ResqueStatus.new self, true
    end
  end

end
