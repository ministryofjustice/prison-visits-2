Rails.application.routes.draw do
  get '/', to: redirect('/staff')

  match 'exception', to: 'errors#test', via: %i[ get post ]

  if Rails.env.test?
    match 'error_handling', to: 'errors#show', via: :get
  end

  constraints format: 'json' do
    get 'ping', to: 'ping#index'
    get 'healthcheck', to: 'healthcheck#index'
  end

  scope '/:locale', locale: /en|cy/ do
    get '/', to: redirect('/%{locale}/request')

    scope controller: :metrics do
      get 'metrics', action: :index
      get 'metrics/confirmed_bookings', action: :confirmed_bookings
      get 'metrics/:prison_id/summary',
        action: :summary,
        as: :prison_metrics_summary
    end

    namespace :prison do
      resources :visits, only: %i[ show update ]
    end
  end

  namespace :api, format: false do
    resources :feedback, only: %i[ create ]
    resources :prisons, only: %i[ index show ]
    resources :slots, only: %i[ index ]
    resources :visits, only: %i[ create show destroy ]
    post '/validations/prisoner', to: 'validations#prisoner'
  end

  get '/staff', to: 'staff_info#index'
  get '/staff/:page', to: 'staff_info#show'
end
