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
      end
    end
  end

  namespace :prison do
    scope controller: :visits do
      get '/visits/:id', action: :show, as: :visit_show
    end

    scope controller: :dashboards do
      get '/', action: :index, as: 'dashboards_root'
      get '/:estate_id', action: :show, as: 'estate_dashboard'
      get '/:estate_id/processed', action: :processed, as: 'processed_visits'
      get '/:estate_id/print_visits', action: :print_visits, as: 'print_visits'
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
