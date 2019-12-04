Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  #

  post '/login', to: 'user#login'
  get '/me', to: 'user#me'
  put '/me/device', to: 'user#device'
  delete '/me/device', to: 'user#remove_device'
  resources :user

  resources :notification, only: [:index, :update]

  resources :invoice_user_payment, only: [:index, :create, :destroy]

  resources :bill do
    resources :bill_user, only: :create, :path => '/bill-user'

    post '/accept', action: :accept
    post '/refuse', action: :refuse

    resources :bill_event, only: [:index, :create, :delete], :path => '/events'
  end

  resources :invoice, only: [:index, :show]

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end
