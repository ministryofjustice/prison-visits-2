Rails.application.config.to_prepare do
  VsipSupportedPrisons.new
end
