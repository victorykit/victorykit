# This code runs GC at the end of every N requests and automatically tunes
# the value of N. The algorithm attempts to optimze when GC runs while
# minimizing CPU utilization.
#
# The code supports a "warm-up" period so the application's memory use
# can stabilize before the auto-tuning kicks in.
#
# The original Unicorn implementation ran GC after a configurable fixed
# number of requests. This was less than optimal as setting N required
# careful monitoring and a bit of guesswork. It also led to higher
# CPU utilization.
#
# The algorithm is controllable via a number of configuration options
# that can be specified when the module is initialized.
#
# This code originated with Unicorn (unicon/oob_gc.rb) and
# has effectively been rewritten.
#

#
# Original comment from the Unicorn implementation.
#
# Runs GC after requests, after closing the client socket and
# before attempting to accept more connections.
#
# This shouldn't hurt overall performance as long as the server cluster
# is at <50% CPU capacity, and improves the performance of most memory
# intensive requests.  This serves to improve _client-visible_
# performance (possibly at the cost of overall performance).
#
# Increasing the number of +worker_processes+ may be necessary to
# improve average client response times because some of your workers
# will be busy doing GC and unable to service clients.  Think of
# using more workers with this module as a poor man's concurrent GC.
#
# We'll call GC after each request is been written out to the socket, so
# the client never sees the extra GC hit it.
#
# This middleware is _only_ effective for applications that use a lot
# of memory, and will hurt simpler apps/endpoints that can process
# multiple requests before incurring GC.
#
# This middleware is only designed to work with unicorn, as it harms
# performance with keepalive-enabled servers.
#
# Example (in config.ru):
#
#     require 'unicorn/oob_gc'
#
#     # GC ever two requests that hit /expensive/foo or /more_expensive/foo
#     # in your app.  By default, this will GC once every 5 requests
#     # for all endpoints in your app
#     use Unicorn::OobGC, 2, %r{\A/(?:expensive/foo|more_expensive/foo)}
#
# Feedback from users of early implementations of this module:
# * http://comments.gmane.org/gmane.comp.lang.ruby.unicorn.general/486
# * http://article.gmane.org/gmane.comp.lang.ruby.unicorn.general/596
module Unicorn::NgOobGC

  class IntervalHistory

    attr_accessor :num_requests, :num_gc, :gc_interval, :consumed

    def initialize
      @num_requests = 0
      @num_gc       = 0
      @gc_interval  = -1
      @consumed     = false
    end

    def to_s
      "req= #{@num_requests} gc= #{@num_gc} interval= #{@gc_interval} consumed= #{@consumed}"
    end

  end

  PATH_INFO = "PATH_INFO"

  # this pretends to be Rack middleware because it used to be
  # But we need to hook into unicorn internals so we need to close
  # the socket before clearing the request env.
  #
  # +_initial_interval+ is the number of requests before invoking GC.
  def self.new(app, initial_interval = 10, options)

    self.const_set :WARM_UP_REQUESTS,                        (options[:warm_up_requets]                         || 250)
    self.const_set :MIN_INTERVAL,                            (options[:min_interval]                            ||   4)
    self.const_set :MAX_INTERVAL,                            (options[:max_interval]                            ||  20)
    self.const_set :INIT_INTERVAL,                           (options[:init_interval]                           ||   8)
    self.const_set :MIN_GC_FOR_INTERVAL_DECREASE,            (options[:min_gc_for_interval_decrease]            ||   3)
    self.const_set :MAX_GC_FOR_INTERVAL_INCREASE,            (options[:max_gc_for_interval_increase]            ||   1)
    self.const_set :INTERVALS_NEEDED_TO_DECREASE_THRESHOLD,  (options[:intervals_needed_to_decrease_threshold]  ||   5)
    self.const_set :INTERVALS_NEEDED_TO_INCREASE_THRESHOLD,  (options[:intervals_needed_to_increase_threshold]  ||   7)
    self.const_set :MAX_INTERVAL_HISTORY,                    (options[:max_interval_history]                    || 100)
    self.const_set :PATH_REGEX_TO_ALWAYS_GC,                 (options[:path_regex_to_always_gc]                 || nil)
    self.const_set :OOBGC_MAX_LOG_LEVEL,                     (options[:log_level]                               ||   2)

    @@oobgc_interval_size               = initial_interval
    @@oobgc_requests                    = 0
    @@oobgc_interval_requests           = 0
    @@oobgc_prev_gc_cnt                 = 0
    @@oobgc_curr_gc_cnt                 = 0
    @@oobgc_total_intra_interval_gc_cnt = 0
    @@oobgc_warmed                      = false

    @@oobgc_interval_history   = [IntervalHistory.new]

    ObjectSpace.each_object(Unicorn::HttpServer) do |s|
      s.extend(self)
      self.const_set :OOBGC_ENV, s.instance_variable_get(:@request).env
    end

    app # pretend to be Rack middleware since it was in the past
  end

  def log(str, log_priority = 1)
    Rails.logger.error("OOBGC: pid= #{Process.pid}  " << str) if (log_priority <= OOBGC_MAX_LOG_LEVEL)
  end

  def process_client(client)
    rt1 = Time.now
    super(client) # Unicorn::HttpServer#process_client
    rt2 = Time.now

    begin

      new_gc = false
      do_gc  = false
      @@oobgc_requests += 1
      @@oobgc_interval_requests += 1
      @@oobgc_curr_gc_cnt = GC.count

      if warmed? && @@oobgc_prev_gc_cnt != @@oobgc_curr_gc_cnt

        @@oobgc_total_intra_interval_gc_cnt += @@oobgc_curr_gc_cnt - @@oobgc_prev_gc_cnt
        record_gc(@@oobgc_curr_gc_cnt - @@oobgc_prev_gc_cnt)

        #
        # A GC just occurred. Since we're trying to optiimize GC frequency and minimize
        # CPU utilization we reset the current interval counter to avoid running an
        # end of interval GC too soon after the recent GC.
        #
        @@oobgc_interval_requests = current_interval_gc_count() + 1

        @@oobgc_prev_gc_cnt = @@oobgc_curr_gc_cnt
        new_gc = true

        log("Unplanned GC: #{ "%2.4f" % (rt2-rt1) }  nr= #{@@oobgc_requests}  ir= #{@@oobgc_interval_requests}/#{@@oobgc_interval_size}  " <<
            "gc= #{@@oobgc_curr_gc_cnt}/#{@@oobgc_total_intra_interval_gc_cnt}/#{ current_interval_gc_count() }#{ (new_gc ? '*' : ' ')}   " <<
            "#{OOBGC_ENV[PATH_INFO]}", (new_gc ? 2 : 3))
      else
        log("              #{ "%2.4f" % (rt2-rt1) }  nr= #{@@oobgc_requests}  ir= #{@@oobgc_interval_requests}/#{@@oobgc_interval_size}  " <<
            "gc= #{@@oobgc_curr_gc_cnt}/#{@@oobgc_total_intra_interval_gc_cnt}/#{ current_interval_gc_count() }#{ (new_gc ? '*' : ' ')}   " <<
            "#{OOBGC_ENV[PATH_INFO]}", 3)
      end


      if @@oobgc_interval_requests >= @@oobgc_interval_size
        OOBGC_ENV.clear

        if warmed?
          adjust_gc_interval()
          advance_history()
        end

        do_gc = true
        @@oobgc_interval_requests = 0
        reason = "Interval"

      elsif PATH_REGEX_TO_ALWAYS_GC && PATH_REGEX_TO_ALWAYS_GC =~ OOBGC_ENV[PATH_INFO]
        do_gc = true
        reason = "Path Match"
      end

      if do_gc
        gct1 = Time.now
        GC.start
        gct2 = Time.now

        @@oobgc_prev_gc_cnt = GC.count

        log("#{reason}  nr= #{@@oobgc_requests}  GC time= #{ "%2.4f" % (gct2-gct1) }  is=#{@@oobgc_interval_size}  gc= #{@@oobgc_curr_gc_cnt}/#{@@oobgc_total_intra_interval_gc_cnt}/#{ current_interval_gc_count() }  stats: #{gc_stats_for_history}")
      end

    rescue => e
      puts e.message + "\n" + e.backtrace.join("\n")
      raise e
    end

  end


  private

    def warmed?
      if @@oobgc_requests >= WARM_UP_REQUESTS && ! @@oobgc_warmed
        @@oobgc_warmed   = true
        @@oobgc_requests = 0     # now that we're warmed up, reset the request counter so the stats aren't off
      end
      @@oobgc_warmed
    end

    def record_gc(n)
      @@oobgc_interval_history.last.num_gc += n
    end

    def current_interval_gc_count
      @@oobgc_interval_history.last.num_gc
    end

    def consume_history(num_intervals)
      if @@oobgc_interval_history.size >= num_intervals
        @@oobgc_interval_history[-num_intervals, num_intervals].each do |ih|
          ih.consumed = true
        end
      end
    end

    # Return the number of gc's for the last N intervals
    def num_gc_for_last_n_intervals(num_intervals, include_consumed = false)
      num_gc = 0
      if @@oobgc_interval_history.size >= num_intervals
        @@oobgc_interval_history[-num_intervals, num_intervals].each do |ih|
          num_gc += ih.num_gc if include_consumed || ! ih.consumed
        end
      end
      num_gc
    end

    def history_size
      @@oobgc_interval_history.size
    end

    # Return the number of requests for the last N intervals
    def num_requests_for_last_n_intervals(num_intervals)
      @@oobgc_requests - @@oobgc_interval_history[-num_intervals].num_requests
    end

    def gc_stats_for_history
      if warmed?
        s = "all:100:10 req/gc/%  "

        num_gc  = @@oobgc_total_intra_interval_gc_cnt
        num_req = @@oobgc_requests
        req_pct = ((num_req - num_gc).to_f / num_req.to_f) * 100
        s << "#{num_req}/#{num_gc}/#{ "%2.1f" % req_pct }%"

        num_gc  = num_gc_for_last_n_intervals(history_size, true)
        num_req = num_requests_for_last_n_intervals(history_size)
        req_pct = ((num_req - num_gc).to_f / num_req.to_f) * 100
        s << " : #{num_req}/#{num_gc}/#{ "%2.1f" % req_pct }%"

        if history_size > 10
          num_gc  = num_gc_for_last_n_intervals(10, true)
          num_req = num_requests_for_last_n_intervals(10)
          req_pct = ((num_req - num_gc).to_f / num_req.to_f) * 100
          s << " : #{num_req}/#{num_gc}/#{ "%2.1f" % req_pct }%"
        end

      else
        s = "insufficient data"
      end

      s
    end

    def sufficient_intervals?(required_intervals)
      avail_intervals = 0
      if history_size >= required_intervals
        @@oobgc_interval_history[-required_intervals, required_intervals].each do |ih|
          avail_intervals += 1 if ! ih.consumed
        end
      end
      avail_intervals == required_intervals
    end

    def adjust_gc_interval()

      prev_interval_size = @@oobgc_interval_size

      if sufficient_intervals?(INTERVALS_NEEDED_TO_DECREASE_THRESHOLD)  &&
         num_gc_for_last_n_intervals(INTERVALS_NEEDED_TO_DECREASE_THRESHOLD) >= MIN_GC_FOR_INTERVAL_DECREASE

        if @@oobgc_interval_size > MIN_INTERVAL
          @@oobgc_interval_size -= 1
          consume_history(INTERVALS_NEEDED_TO_DECREASE_THRESHOLD)
        end

      elsif sufficient_intervals?(INTERVALS_NEEDED_TO_INCREASE_THRESHOLD)  &&
            num_gc_for_last_n_intervals(INTERVALS_NEEDED_TO_INCREASE_THRESHOLD) <= MAX_GC_FOR_INTERVAL_INCREASE

        if @@oobgc_interval_size < MAX_INTERVAL
          @@oobgc_interval_size += 1
          consume_history(INTERVALS_NEEDED_TO_INCREASE_THRESHOLD)
        end

      end

      if @@oobgc_interval_size != prev_interval_size
        log("Interval CHANGED! old: #{prev_interval_size} new: #{@@oobgc_interval_size}  " <<
             "nr= #{@@oobgc_requests}  ir= #{@@oobgc_interval_requests}/#{@@oobgc_interval_size} ", 2)
      end
    end

    def dump_history(n = 10)
      ih_size = @@oobgc_interval_history.size
      (1..n).each do |i|
        ih = @@oobgc_interval_history[-i]
        log("#{ih_size - i}/#{ih_size}  #{ih.to_s}", 99) if ih
      end
    end

    def advance_history
      @@oobgc_interval_history.last.num_requests = @@oobgc_requests

      dump_history if OOBGC_MAX_LOG_LEVEL >= 9

      @@oobgc_interval_history << IntervalHistory.new
      @@oobgc_interval_history.last.gc_interval = @@oobgc_interval_size

      # Toss the eldest history if we've reached the max num of intervals to keep
      @@oobgc_interval_history.shift if @@oobgc_interval_history.size > MAX_INTERVAL_HISTORY

    end

end
