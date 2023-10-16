Rails.application.config.assets.version = '1.2'

Rails.application.config.assets.precompile += %w[
  application.css
  application-ie6.css
  application-ie7.css
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
