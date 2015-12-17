module WithRetries
protected

  def with_retries(attempts: 10, initial_delay: 2, max_delay: 120)
    delay = initial_delay
    result = nil
    attempts.times do
      result = yield
      break if result
      puts "waiting #{delay}s .."
      sleep delay
      delay = [max_delay, delay * 2].min
    end
    result
  end
end
