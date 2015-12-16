class Healthcheck
  class DatabaseCheck
    include CheckComponent

    def initialize(description)
      build_report description do
        { ok: ActiveRecord::Base.connection.active? }
      end
    end
  end
end
