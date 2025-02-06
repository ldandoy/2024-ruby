Rails.application.routes.draw do
  root "weight_entries#index"
  resources :weight_entries
end
