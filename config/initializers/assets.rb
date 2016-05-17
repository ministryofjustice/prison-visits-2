Rails.application.config.assets.version = '1.0'

Rails.application.config.assets.precompile += %w[
  email.css
  back-office.css
  *.png
  favicon.ico
  metrics.css
  gov.uk_logotype_crown.svg
]

Rails.application.config.assets.paths <<
  "#{Rails.root}/vendor/assets/moj.slot-picker/dist/stylesheets"
