Rails.application.config.assets.version = '1.2'

Rails.application.config.assets.precompile += %w[
  application-ie8.css
  email.css
  *.png
  *.svg
  *.jpg
  favicon.ico
  metrics.css
  metrics.js
  gov.uk_logotype_crown.svg
  *.eot
  *.svg
  *.ttf
  *.woff
  jasmine-jquery.js
]
