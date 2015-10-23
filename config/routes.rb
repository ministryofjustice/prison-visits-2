Rails.application.routes.draw do
  resources :steps, path: 'visit', only: [:index, :create]
end
