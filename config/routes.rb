Rails.application.routes.draw do
  get '/', to: redirect(ENV.fetch('GOVUK_START_PAGE', '/request'))

  resources :booking_requests, path: 'request', only: %i[ index create ]
  resources :visits, only: %i[ show ]
  resources :cancellations, path: 'cancel', only: %i[ create ]
  resources :feedback_submissions, path: 'feedback', only: %i[ new create ]

  namespace :prison do
    resources :visits, only: %i[ edit update ]
  end

  get 'unsubscribe' => 'high_voltage/pages#show', id: 'unsubscribe'
  get 'ping' => 'ping#index'
end
