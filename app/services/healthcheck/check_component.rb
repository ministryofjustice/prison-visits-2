class Healthcheck
  module CheckComponent
    attr_reader :report

    def ok?
      report.fetch(:ok)
    end

  private

    def build_report(description)
      @report =
        begin
          yield
        rescue StandardError => err
          { error: err.to_s, ok: false }
        end.merge(description: description)
    end
  end
end
