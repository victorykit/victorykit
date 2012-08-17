class TestResqueJob
  @queue = :test_queue

  def self.perform val
    Rails.logger.warn "*** Testing Resque: #{val}"
  end
end