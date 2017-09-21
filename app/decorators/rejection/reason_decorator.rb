class Rejection::ReasonDecorator < Draper::Decorator
  delegate_all
  def checkbox_for(reason, html_options = {})
    html_options[:id] = nil unless html_options.key?(:id)
    has_reason = object.include?(reason.to_s)

    if has_reason
       html_options[:class] = html_options[:class] ||= ''
       html_options[:class] += ' js-Rejection js-restrictionOverride'
    end

    h.check_box_tag(
      'visit[rejection_attributes][reasons][]',
      reason,
      has_reason,
      html_options
    )
  end
end
