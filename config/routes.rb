# frozen_string_literal: true

Rails.application.routes.draw do
  # API DOCS
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  get '/stores', to: 'stores#index'
  get '/stores/:id', to: 'stores#show'
  get 'stores/:id/inventories/transfer_suggestions', to: 'inventory_transfer_suggestions#show'
  post '/stores/:id/inventories/transfers', to: 'inventory_transfers#create'
  patch '/stores/:id/products/:product_id/inventories/settings', to: 'inventory_settings#edit'
end
