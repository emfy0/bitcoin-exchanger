Rails.application.routes.draw do
  root to: "transactions#new"

  resource :transactions, only: %i[new create]
end
