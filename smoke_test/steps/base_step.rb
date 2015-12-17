module SmokeTest
  module Steps
    class BaseStep
      include Capybara::DSL

      attr_accessor :state

      def initialize(state)
        puts "Step:#{step_name}"
        @state = state
      end

      def validate!
        true
      end

      def complete_step
        fail NotImplementedError
      end

    protected

      def step_name
        self.class.name.split('::').last.gsub(/(?=[A-Z])/, ' ')
      end

    end
  end
end
