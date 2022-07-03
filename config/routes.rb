Rails.application.routes.draw do
  root to: "transactions#new"

  get '/stats', to: 'admin_panel#show'

  resources :transactions, only: %i[new create show]

  mount ActionCable.server => '/cable'
end
