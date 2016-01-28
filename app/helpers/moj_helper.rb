module MojHelper
  def config_item(key)
    if key == :proposition_title
      I18n.t('app_title')
    else
      Rails.configuration.public_send(key)
    end
  end
end
