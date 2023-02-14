Rails.application.routes.draw do
  get '/stores', to: 'stores#index'
  get '/stores/:id', to: 'stores#show'
end
