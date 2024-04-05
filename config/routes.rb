Rails.application.routes.draw do
  root 'weather#show'

  resource :weather, only: [:show]
end
