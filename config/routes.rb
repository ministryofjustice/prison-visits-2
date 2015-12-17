Rails.application.routes.draw do
  prison_ip_matcher =
    IpAddressMatcher.new(Rails.configuration.prison_ip_ranges)

  get '/', to: redirect(ENV.fetch('GOVUK_START_PAGE', '/request'))

  resources :booking_requests, path: 'request', only: %i[ index create ]
  resources :visits, only: %i[ show ]
  resources :cancellations, path: 'cancel', only: %i[ create ]
  resources :feedback_submissions, path: 'feedback', only: %i[ new create ]

  constraints ip: prison_ip_matcher do
    namespace :prison do
      resources :visits, only: %i[ show update ]
    end
  end

  controller 'high_voltage/pages' do
    get 'terms-and-conditions', action: :show, id: 'terms_and_conditions'
    get 'unsubscribe', action: :show, id: 'unsubscribe'
  end

  constraints format: 'json' do
    get 'ping', to: 'ping#index'
    get 'healthcheck', to: 'healthcheck#index'
  end
end
