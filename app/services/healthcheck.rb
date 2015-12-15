require 'sidekiq/api'

class Healthcheck
  STALENESS_THRESHOLD = 10.minutes

  def initialize
    @queues = {}
  end

  def ok?
    checks.fetch(:ok)
  end

  def checks
    components = {
      database: database,
      mailers: mailers,
      zendesk: zendesk
    }
    components.merge(ok: components.values.map { |h| h.fetch(:ok) }.all?)
  end

private

  def database
    {
      description: 'Postgres database',
      ok: database_active?
    }
  end

  def mailers
    queue_info('mailers', 'Email queue')
  end

  def zendesk
    queue_info('zendesk', 'Zendesk queue')
  end

  def queue_info(name, description)
    q = Sidekiq::Queue.new(name)
    {
      description: description,
      ok: fresh?(q),
      oldest: oldest(q),
      count: q.count
    }
  rescue StandardError
    { description: description, ok: false, oldest: nil, count: 0 }
  end

  def fresh?(q)
    return true unless q.any?
    q.first.created_at > STALENESS_THRESHOLD.ago
  end

  def oldest(q)
    q.any? ? q.first.created_at : nil
  end

  def database_active?
    ActiveRecord::Base.connection.active?
  rescue StandardError
    false
  end
end
