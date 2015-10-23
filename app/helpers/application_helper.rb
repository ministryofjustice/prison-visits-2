module ApplicationHelper
  def page_title(header, glue = ' - ')
    [header, I18n.t(:app_title)].compact.join(glue)
  end

  def single_field(form, name, field_method, *options)
    error_container(form, name, class: 'group') {
      join(
        form.label(name) {
          join(
            t(".#{name}"),
            field_hint(name),
            field_error(form, name)
          )
        },
        form.public_send(field_method, name, *options)
      )
    }
  end

  def composite_field(form, name, &blk)
    error_container(form, name, class: 'group') {
      content_tag(:fieldset) {
        join(
          content_tag(:legend) { t(".#{name}") },
          content_tag(:div) {
            join(
              field_hint(name),
              capture(&blk)
            )
          }
        )
      }
    }
  end

  def field_error(form, name)
    errors = form.object.errors[name]
    return '' unless errors.any?
    content_tag(:span, class: 'validation-message') { errors.first }
  end

  def field_hint(name)
    text = t(".#{name}_hint", default: '')
    if text.present?
      content_tag(:p, class: 'form-hint') { text }
    else
      ''
    end
  end

  def error_container(form, name, options = {}, &blk)
    if form.object.errors.include?(name)
      klass = [options[:class], 'validation-error'].compact.join(' ')
    else
      klass = options[:class]
    end
    content_tag(:div, options.merge(class: klass), &blk)
  end

private

  def join(*strings)
    strings.inject(ActiveSupport::SafeBuffer.new(''), &:<<)
  end
end
