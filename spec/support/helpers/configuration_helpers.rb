module ConfigurationHelpers
  def switch_on(feature_flag)
    switch_feature_flag_with(feature_flag, true)
  end

  def switch_off(feature_flag)
    switch_feature_flag_with(feature_flag, false)
  end

  def switch_feature_flag_with(feature_flag, values)
    allow(Rails.configuration).to receive(feature_flag).and_return(values)
  end
  alias_method :set_configuration_with, :switch_feature_flag_with
end
