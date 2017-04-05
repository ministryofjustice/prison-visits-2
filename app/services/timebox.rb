# Runs provided block within the time limit or else returns the result of the
# fallback block. run may be called multiple times; the original time limit
# being applied to all runs collectively.
# Time limit may be an integer or a float.
class Timebox
  def initialize(time_limit_seconds, start_time = Time.now.to_f)
    @deadline = start_time + time_limit_seconds
  end

  def run(fallback_block)
    return fallback(fallback_block) if seconds_expired?

    Timeout.timeout(seconds_remaining) { yield }.tap do
      PVB::Instrumentation.append_to_log(timebox_exceeded: false)
    end

  rescue Timeout::Error
    fallback(fallback_block)
  end

private

  def fallback(block)
    block.call.tap do
      PVB::Instrumentation.append_to_log(timebox_exceeded: true)
    end
  end

  def seconds_remaining
    @deadline - Time.now.to_f
  end

  def seconds_expired?
    seconds_remaining <= 0.0
  end
end
