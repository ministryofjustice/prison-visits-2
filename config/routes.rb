Rails.application.routes.draw do
  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
  root to: 'staff_info#show'

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
      get 'metrics/send_confirmed_bookings', action: :send_confirmed_bookings
      get 'metrics/:prison_id/summary',
        action: :summary,
        as: :prison_metrics_summary
      get 'metrics/digital_takeup', action: :digital_takeup
    end

    namespace :prison do
      resources :visits, only: %i[show update] do
        member do
          post 'nomis_cancelled'
          post 'cancel'
        end

        resources :messages, only: :create
        resource :email_preview, only: :update
      end
    end
  end

  namespace :prison do
    ### deprecated, for backwards compatibility. Delete soon after deploying
    resources :visits, only: %i[show update] do
      member do
        post 'nomis_cancelled'
        post 'cancel'
      end

      resources :messages, only: :create
    end

    resources :visits, only: [] do
      resource :email_preview, only: :update
    end
    #######

    scope controller: :dashboards do
      get '/inbox', action: :inbox, as: 'inbox'
      get '/processed', action: :processed, as: 'processed_visits'
      get '/print_visits', action: :print_visits, as: 'print_visits'
      get '/search', action: :search, as: :search
    end

    resource :switch_estates, only: %i[ create ]
    resources :feedbacks, only: %i[ new create ]
  end

  namespace :api, format: false do
    resources :feedback,        only: %i[ create ]
    resources :prisons,         only: %i[ index show ]
    resources :slots,           only: %i[ index ]
    resources :visits,          only: %i[ create show destroy ]
    post '/validations/prisoner', to: 'validations#prisoner'
    post '/validations/visitors', to: 'validations#visitors'
  end

  resource :staff, only: :show, controller: 'staff_info' do
    resources :downloads, only: :index
    resource :telephone_script, only: :show
  end
end
