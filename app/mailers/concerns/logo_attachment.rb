module LogoAttachment
  extend ActiveSupport::Concern

  included do
    before_action :attach_logo
  end

  def attach_logo
    attachments.inline['govuk-header-logo.png'] = {
      content: File.read(
        Rails.root.join('public', 'mailers', 'govuk-header-logo.png')
      ),
      mime_type: 'image/png'
    }
  end
end
