Rails.application.routes.draw do
  namespace :api do
    resources :people, only: %i(index)
  end
end
