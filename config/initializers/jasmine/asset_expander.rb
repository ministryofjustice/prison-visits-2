# https://github.com/jasmine/jasmine-gem/blob/v3.9.2/lib/jasmine/asset_expander.rb

unless Rails.env.production?
  module Jasmine
    class AssetExpander
    private

      def asset_bundle
        return Rails4Or5Or6AssetBundle.new if Jasmine::Dependencies.rails4? ||
          Jasmine::Dependencies.rails5? ||
          Jasmine::Dependencies.rails6? ||
          Jasmine::Dependencies.rails7?

        raise UnsupportedRailsVersion, 'Jasmine only supports the asset pipeline for Rails 4. - 7'
      end
    end
  end
end
