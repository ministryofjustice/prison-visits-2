module Jasmine
  module Dependencies
    class << self
      def rails7?
        rails? && Rails.version.to_i == 7
      end

      def use_asset_pipeline?
        (rails4? || rails5? || rails6? || rails7?) &&
          Rails.respond_to?(:application) &&
          Rails.application.respond_to?(:assets) &&
          !Rails.application.assets.nil?
      end
    end
  end
end
