Rails.application.routes.draw do
  get '/', to: redirect(ENV.fetch('GOVUK_START_PAGE', '/visit'))

  resources :steps, path: 'visit', only: %i[ index create ]

  namespace :prison do
    resources :visits, only: %i[ edit update ]
  end

  get 'unsubscribe' => 'high_voltage/pages#show', id: 'unsubscribe'
end
