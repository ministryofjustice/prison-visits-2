if Rails.env.production? && Rails.configuration.kubernetes_deployment && ENV['DISABLE_PROMETHEUS_METRICS'].blank?
  require 'prometheus_exporter/instrumentation'
  require 'prometheus_exporter/middleware'

  PrometheusExporter::Instrumentation::Process.start(type: 'master')
  Rails.application.middleware.unshift PrometheusExporter::Middleware
end
