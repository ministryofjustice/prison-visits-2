Rails.application.routes.draw do
  get '/', to: redirect(ENV.fetch('GOVUK_START_PAGE', '/en/request'))

  %w[ 404 500 503 ].each do |code|
    match code, to: 'errors#show', status_code: code, via: %i[ get post ]
  end
  match 'exception', to: 'errors#test', via: %i[ get post ]

  constraints format: 'json' do
    get 'ping', to: 'ping#index'
    get 'healthcheck', to: 'healthcheck#index'
  end

  scope '/:locale', locale: /[a-z]{2}/ do
    get '/', to: redirect('/%{locale}/request')

    scope controller: :metrics do
      get 'metrics', action: :index
    end

    namespace :prison do
      resources :visits, only: %i[ show update ]
    end

    resources :booking_requests, path: 'request', only: %i[ index create ]
    resources :visits, only: %i[ show ]
    resources :cancellations, path: 'cancel', only: %i[ create ]
    resources :feedback_submissions, path: 'feedback', only: %i[ new create ]

    controller 'high_voltage/pages' do
      get 'cookies', action: :show, id: 'cookies'
      get 'terms-and-conditions', action: :show, id: 'terms_and_conditions'
      get 'unsubscribe', action: :show, id: 'unsubscribe'
    end
  end

  namespace :api, constraints: { format: 'json' } do
    get '/', to: 'root#index'
    resources :prisons, only: %i[ index show ]
    resources :slots, only: %i[ index ]
  end
end
