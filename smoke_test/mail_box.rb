require 'mail'
require 'net/imap'

module SmokeTest
  module MailBox
  module_function

    def find_email(unique_address, subject)
      client = Net::IMAP.new(SMOKE_TEST_EMAIL_HOST, port: 993, ssl: true)
      client.login imap_username, SMOKE_TEST_EMAIL_PASSWORD
      client.examine 'INBOX'
      mail_id_list = client.search(['TO', unique_address, 'SUBJECT', subject])

      return if mail_id_list.empty? # empty lists appear to break imap->fetch

      client.fetch(mail_id_list, 'RFC822').map(&method(:parse_email)).first
    ensure
      client.logout
      client.disconnect
    end

    def parse_email(msg)
      Mail.read_from_string(msg.attr['RFC822'])
    end

    def imap_username
      "#{SMOKE_TEST_EMAIL_LOCAL_PART}@#{SMOKE_TEST_EMAIL_DOMAIN}"
    end

    private_class_method :parse_email, :imap_username
  end
end
