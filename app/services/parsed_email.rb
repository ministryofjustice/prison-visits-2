class ParsedEmail
  include NonPersistedModel

  ParseError = Class.new(StandardError)

  attribute :from, String
  attribute :to, String
  attribute :subject, String
  attribute :text, String

  # rubocop:disable Metrics/AbcSize
  def self.parse(hash)
    hash = hash.dup
    fail ParseError, 'Missing subject' unless hash[:subject]
    fail ParseError, 'Missing email body' unless hash[:text]
    charsets = JSON.parse(hash[:charsets]).with_indifferent_access

    [:subject, :text].each do |field|
      # Fields can have different encodings, normalize everything to UTF-8
      encoding = charsets[field]

      hash[field].force_encoding(encoding).encode!('UTF-8') if encoding
    end

    new new_parse(hash)
  end
  # rubocop:enable Metrics/AbcSize

  def self.new_parse(hash)
    {
      to: Mail::Address.new(hash[:to]),
      from: Mail::Address.new(hash[:from]),
      subject: hash[:subject],
      text: hash[:text]
    }
  end

  def source
    from.domain.in?(%w[hmps.gsi.gov.uk noms.gsi.gov.uk]) ? :prison : :visitor
  end
end
