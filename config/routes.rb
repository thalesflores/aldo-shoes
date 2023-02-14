Rails.application.routes.draw do
  get '/stores', to: 'stores#index'
  get '/stores/:id', to: 'stores#show'
  post '/stores/:id/inventories/transfers', to: 'inventory_transfers#create'
end
