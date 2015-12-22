module ImapProcessor
module_function

  def email
    @email ||= with_retries {
      SmokeTest::MailBox.find_email(
        state.unique_email_address,
        expected_email_subject)
    }
  end

  private_class_method :email

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
