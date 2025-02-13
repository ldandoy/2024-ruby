Rails.application.routes.draw do
  devise_for :users
  root "weight_entries#index"
  resources :weight_entries
end
