require 'ostruct'
require 'yaml'
require 'erb'

module SmokeTest
  class State
    attr_accessor :slot_data

    TEST_DATA = YAML.load(
      ERB.new(
        File.read(File.expand_path('../test_data.yml', __FILE__))
      ).result)

    def prisoner
      @prisoner ||= Prisoner.new
    end

    def visitor
      @visitor ||= Visitor.new
    end

    def process_data
      @process_data ||= OpenStruct.new(TEST_DATA.fetch 'process_data')
    end

    def unique_email_address
      visitor.email_address
    end

    def first_slot_date
      slot_data.first[:date]
    end

    alias_method :first_slot_date_prison_format, :first_slot_date

    def first_slot_date_visitor_format
      Date.parse(first_slot_date).strftime('%A %-d %B')
    end

    class Prisoner < SimpleDelegator
      def initialize
        super(OpenStruct.new State::TEST_DATA.fetch('prisoner_details'))
      end

      def full_name
        "#{first_name} #{last_name}"
      end
    end

    class Visitor < SimpleDelegator
      def initialize
        super(OpenStruct.new State::TEST_DATA.fetch('visitor_details'))
      end

      def email_address
        @email_address ||= UniqueEmailAddress.new
      end

      class UniqueEmailAddress < String
        def initialize(*)
          uuid = SecureRandom.uuid
          super \
            "#{SMOKE_TEST_EMAIL_LOCAL_PART}+#{uuid}@#{SMOKE_TEST_EMAIL_DOMAIN}"

          freeze
        end
      end
    end
  end
end
