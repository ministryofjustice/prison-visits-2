Rails.application.config.assets.version = '1.0'

Rails.application.config.assets.precompile += %w[
  application-ie8.css
  email.css
  back-office.css
  *.png
  *.svg
  favicon.ico
  metrics.css
  metrics.js
  gov.uk_logotype_crown.svg
  *.eot
  *.svg
  *.ttf
  *.woff
]

Rails.application.config.assets.paths <<
  "#{Rails.root}/vendor/assets/moj.slot-picker/dist/stylesheets"
