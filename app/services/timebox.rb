# An object that runs a provided block within the time limit or else returns
# the result of the fallback block. run may be called multiple times; the
# original time limit being applied to all runs collectively.
class Timebox
  def initialize(time_limit)
    @deadline = Time.now.to_i + time_limit
  end

  def run(fallback_block)
    time_remaining = @deadline - Time.now.to_i
    return fallback_block.call if time_remaining <= 0

    Timeout.timeout(time_remaining) { yield }.tap do
      PVB::Instrumentation.append_to_log(timebox_exceeded: false)
    end

  rescue Timeout::Error
    PVB::Instrumentation.append_to_log(timebox_exceeded: true)
    fallback_block.call
  end
end
