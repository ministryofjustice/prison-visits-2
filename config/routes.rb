require 'pvb/digital_user_constraint'

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
    get 'info', to: 'info#index'
    get 'health', to: 'health#index'
  end

  get '/auth/:provider/callback', to: 'sessions#create'
  resource :session, only: %i[ destroy ]

  scope '/:locale', locale: /en|cy/ do
    get '/', to: redirect('/')

    namespace :prison do
      resources :visits, only: %i[show update] do
        resource :cancellations, only: :create
        member do
          post 'nomis_cancelled'
        end

        resources :messages, only: :create
      end
    end
  end

  namespace :prison do
    resource :print_visit, only: %i[new show]

    scope controller: :dashboards do
      get '/inbox', action: :inbox, as: 'inbox'
      get '/processed', action: :processed, as: 'processed_visits'
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

  constraints ->(req) { PVB::DigitalUserConstraint.new.matches?(req) } do
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
  end
end
