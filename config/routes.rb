Rails.application.routes.draw do
  root "static_pages#show"

  resource :weather, controller: "weather", only: [:show]
end
