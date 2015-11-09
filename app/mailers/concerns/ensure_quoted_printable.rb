# Sendgrid enforces line length limits of 998 characters. This
# is according to the RFC spec: http://tools.ietf.org/html/rfc5322
# see section 2.1.1 for more info.
#
# It will break lines with a new line when the limit is reached,
# this can break links.
#
# This module when included in a Mailer will ensure the
# Content-Transfer-Encoding header is set to quoted-printable
# which results in correctly formatted html and text emails.

module EnsureQuotedPrintable
  extend ActiveSupport::Concern

  included do
    after_action { message.transport_encoding = 'quoted-printable' }
  end
end
