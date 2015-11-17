Rails.application.routes.draw do
  resources :steps, path: 'visit', only: [:index, :create]
  get '/', to: redirect(ENV.fetch('GOVUK_START_PAGE', '/visit'))
end
