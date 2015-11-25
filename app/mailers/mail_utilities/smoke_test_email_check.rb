class SmokeTestEmailCheck
  attr_accessor :email_address

  def initialize(email_address)
    @email_address = email_address
  end

  def matches?
    smoke_test_email_regex.match(email_address)
  end

private

  def smoke_test_email_regex
    %r{
      \A             # match from the start of the string
      #{local_part}
      \+             # google address alias see: https://support.google.com/mail/answer/12096
      [0-9a-z\-]{36} # RFC 4122 uuid extension
      @              # it's an email!
      #{domain}
      \z             # match until the end of the string
    }x
  end

  def smoke_test
    Rails.configuration.smoke_test
  end

  delegate :local_part, :domain, to: :smoke_test
end
