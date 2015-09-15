Rails.application.routes.draw do

  root :to => "stations#index"
  get "/stations/status", to: "stations#status"
  resources :stations

end
