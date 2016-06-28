# This class will go away when we start using the form builder gem
# :nocov:
module FormElementsHelper
  def single_field(form, name, field_method, *options)
    case field_method
    when :radio_button, :check_box
      label_wrapped_single_field(form, name, field_method, *options)
    else
      label_first_single_field(form, name, field_method, *options)
    end
  end

  def field_error(form, name)
    errors = form.object.errors[name]
    return '' unless errors.any?
    content_tag(:span, class: 'validation-message') { errors.first }
  end

  def field_hint(name)
    text = t(".#{name}_hint", default: '')
    if text.present?
      content_tag(:span, class: 'form-hint') { text }
    else
      ''
    end
  end

  def error_container(form, name, options = { class: 'group' }, &blk)
    if form.object.errors.include?(name)
      klass = [options[:class], 'validation-error'].compact.join(' ')
    else
      klass = options[:class]
    end
    content_tag(:div, options.merge(class: klass), &blk)
  end

private

  def label_first_single_field(form, name, field_method, *options)
    error_container(form, name) {
      join(
        form.label(name, class: 'form-label') {
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

  def label_wrapped_single_field(form, name, field_method, *options)
    error_container(form, name) {
      join(
        form.label(name, class: 'block-label') {
          join(
            form.public_send(field_method, name, *options),
            t(".#{name}"),
            field_hint(name),
            field_error(form, name)
          )
        }
      )
    }
  end

  def join(*strings)
    strings.inject(ActiveSupport::SafeBuffer.new(''), &:<<)
  end
end
