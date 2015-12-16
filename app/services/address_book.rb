class AddressBook
  def initialize(domain)
    @domain = domain
  end

  def feedback
    "feedback@#{@domain}"
  end

  def no_reply
    "no-reply@#{@domain}"
  end
end
