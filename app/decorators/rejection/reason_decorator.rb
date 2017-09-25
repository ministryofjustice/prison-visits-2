class Rejection::ReasonDecorator < Draper::Decorator
  delegate_all
  def checkbox_for(reason, html_options = {})
    html_options_defaults(html_options)

    reason = reason.to_s
    has_reason = object.include?(reason)

    html_options[:data][:override] = reason.dasherize
    html_options[:class] = html_class(has_reason, html_options[:class])

    h.check_box_tag(
      'visit[rejection_attributes][reasons][]', reason, has_reason, html_options)
  end

  def html_options_defaults(html_options)
    html_options[:id] = nil unless html_options.key?(:id)
    html_options[:data] ||= {}
  end

  def html_class(has_reason, default_class)
    new_classes = [default_class, 'js-Rejection'].compact
    new_classes << 'js-restrictionOverride' if has_reason
    new_classes.join(' ')
  end
end
