module MojHelper
  def config_item(key)
    {
      phase: Rails.configuration.phase,
      product_type: Rails.configuration.product_type,
      proposition_title: I18n.t('app_title')
    }.fetch(key)
  end
end
