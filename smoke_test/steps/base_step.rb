module SmokeTest
  module Steps
    class BaseStep
      include Capybara::DSL
      extend Forwardable

    protected

      def state
        SmokeTest::Runner.state
      end
    end
  end
end
