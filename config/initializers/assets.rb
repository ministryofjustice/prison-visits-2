# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.2'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
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
