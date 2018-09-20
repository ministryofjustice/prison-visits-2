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

  def accessible_date_options
    {
      day:   { min: 1, max: 31 },
      month: { min: 1, max: 12 },
      year:  { min: Date.current.year }
    }
  end

  def visit_date_options
    {
      day:   { min: 1, max: 31 },
      month: { min: 1, max: 12 },
      year:  { min: Date.new(2014, 1, 1).year }
    }
  end

  def composite_field(form, name, &blk)
    error_container(form, name) {
      content_tag(:fieldset) {
        join(
          content_tag(:legend) {
            join(
              content_tag(:span, class: 'form-label-bold') {
                t(".#{name}")
              },
              field_error(form, name),
              field_hint(name)
            )
          },
          content_tag(:div, class: 'form-date') {
            capture(&blk)
          }
        )
      }
    }
  end

  def field_error(form, name)
    return unless form.object

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

  def error_container(form, name, options = { class: 'form-group' }, &blk)
    if form.object&.errors&.include?(name)
      klass = [options[:class], 'form-group-error error'].compact.join(' ')
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
    label_class = options.delete(:no_block) ? 'form-checkbox' : 'block-label'

    error_container(form, name) {
      content_tag(:div, class: 'multiple-choice'){
        join(
          form.public_send(field_method, name, *options),
          form.label(name, class: label_class) {
            join(
              t(".#{name}"),
              field_hint(name),
              field_error(form, name)
            )
          }
        )
      }
    }
  end

  def join(*strings)
    strings.inject(ActiveSupport::SafeBuffer.new(''), &:<<)
  end
end
# :nocov:
