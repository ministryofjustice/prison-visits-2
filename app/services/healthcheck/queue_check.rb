class Healthcheck
  class QueueCheck
    include CheckComponent

    STALENESS_THRESHOLD = 10.minutes

    def initialize(description, queue_name:)
      build_report description do
        queue = Sidekiq::Queue.new(queue_name)
        {
          ok: fresh?(queue),
          oldest: oldest(queue),
          count: queue.count
        }
      end
    end

  private

    def fresh?(queue)
      return true unless queue.any?

      queue.first.created_at > STALENESS_THRESHOLD.ago
    end

    def oldest(queue)
      queue.any? ? queue.first.created_at : nil
    end
  end
end
