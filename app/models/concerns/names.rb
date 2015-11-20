module Names
  # rubocop:disable Metrics/MethodLength
  def enhance_names(prefix: nil)
    method_prefix = prefix ? "#{prefix}_" : ''

    define_method "#{method_prefix}full_name" do
      I18n.t(
        'formats.name.full',
        first: public_send("#{method_prefix}first_name"),
        last: public_send("#{method_prefix}last_name")
      )
    end

    define_method "#{method_prefix}anonymized_name" do
      I18n.t(
        'formats.name.full',
        first: public_send("#{method_prefix}first_name"),
        last: public_send("#{method_prefix}last_name")[0]
      )
    end
  end
end
