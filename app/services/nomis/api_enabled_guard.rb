module Nomis
  module ApiEnabledGuard
    def self.included(base)
      base.extend ClassMethods
      base.const_set('NOT_LIVE', 'not_live'.freeze)
    end

    module ClassMethods
      def method_added(method_name)
        if wrap_method?(method_name)
          api_method = instance_method method_name
          method_redefined << method_name

          define_method method_name do |*args|
            return self.class::NOT_LIVE unless Nomis::Api.enabled?

            api_method.bind(self).call(*args)
          end
        end

        @wrap_next_method_definition = false
      end

    private

      def wrap_method?(method_name)
        wrap_next_method_definition && !method_redefined.include?(method_name)
      end

      def method_redefined
        @method_redefined ||= []
      end

      def check_nomis_enabled
        @wrap_next_method_definition = true
      end

      def wrap_next_method_definition
        @wrap_next_method_definition ||= false
      end
    end
  end
end
