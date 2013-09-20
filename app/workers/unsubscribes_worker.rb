class UnsubscribesWorker
  include Sidekiq::Worker

  def perform(email, batch_key)
    REDIS.incr "#{batch_key}.seen_lines"

    member = Member.lookup(email).first
    if member
      REDIS.incr "#{batch_key}.members"
      u = Unsubscribe.new(email: email, member: member, cause: 'uploaded')
      REDIS.incr "#{batch_key}.unsubscribes" if u.save
    end
  end
end