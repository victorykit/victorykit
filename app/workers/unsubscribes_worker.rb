class UnsubscribesWorker
  include Sidekiq::Worker

  def perform(line, batch_key)
    REDIS.incr "#{batch_key}.seen_lines"

    member = Member.where("lower(email) = ?", line.downcase).first
    if member
      REDIS.incr "#{batch_key}.members"
      u = Unsubscribe.new(email: line, member: member, cause: 'uploaded')
      REDIS.incr "#{batch_key}.unsubscribes" if u.save
    end
  end
end