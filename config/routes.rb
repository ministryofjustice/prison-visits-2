Rails.application.routes.draw do
  resources :prisoner_steps, path: 'prisoner', only: [:new, :create]
end
