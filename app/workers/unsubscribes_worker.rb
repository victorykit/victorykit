class UnsubscribesWorker
  include Sidekiq::Worker

  def perform(email, cause, batch_key = nil)
    REDIS.incr "#{batch_key}.seen_lines" if batch_key

    member = Member.lookup(email).first
    if member
      REDIS.incr "#{batch_key}.members" if batch_key
      u = Unsubscribe.new(email: email, member: member, cause: cause)
      REDIS.incr "#{batch_key}.unsubscribes" if u.save && batch_key
    end
  end

end
