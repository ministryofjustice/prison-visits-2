Rails.application.routes.draw do
  root to: 'staff_info#index'

  match 'exception', to: 'errors#test', via: %i[ get post ]

  if Rails.env.test?
    match 'error_handling', to: 'errors#show', via: :get
  end

  constraints format: 'json' do
    get 'ping', to: 'ping#index'
    get 'healthcheck', to: 'healthcheck#index'
  end

  get '/auth/:provider/callback', to: 'sessions#create'
  resource :session, only: %i[ destroy ]

  scope '/:locale', locale: /en|cy/ do
    get '/', to: redirect('/')

    scope controller: :metrics do
      get 'metrics', action: :index
      get 'metrics/confirmed_bookings', action: :confirmed_bookings
      get 'metrics/:prison_id/summary',
        action: :summary,
        as: :prison_metrics_summary
    end

    namespace :prison do
      scope controller: :visits do
        get '/visits/:id', action: :process_visit, as: :visit_process
        put '/visits/:id', action: :update, as: :visit
        get '/visits/deprecated/:id',
          action: :deprecated_show,
          as: :deprecated_visit
        delete '/visits/:id', action: :cancel, as: :cancel_visit
      end
    end
  end

  namespace :prison do
    scope controller: :visits do
      get '/visits/:id', action: :show, as: :visit_show
      post '/visits/:id/confirm_nomis_cancellation',
        action: :nomis_cancelled,
        as: :confirm_nomis_cancellation_visit
    end

    scope controller: :dashboards do
      get '/inbox', action: :inbox, as: 'inbox'
      get '/processed', action: :processed, as: 'processed_visits'
      get '/print_visits', action: :print_visits, as: 'print_visits'
      get '/search', action: :search, as: :search
    end
  end

  namespace :api, format: false do
    resources :feedback, only: %i[ create ]
    resources :prisons, only: %i[ index show ]
    resources :slots, only: %i[ index ]
    resources :visits, only: %i[ create show destroy ]
    post '/validations/prisoner', to: 'validations#prisoner'
    post '/validations/visitors', to: 'validations#visitors'
  end

  get '/staff', to: 'staff_info#index'
  get '/staff/:page', to: 'staff_info#show'
end
