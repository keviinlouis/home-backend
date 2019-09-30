Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  #
  resources :bill do
    resources :bill_user, only: :create, :path => '/bill-user'

    post '/accept', action: :accept
    post '/refuse', action: :refuse

    resources :bill_event, only: [:index, :create, :delete], :path => '/events'
  end

  post 'invoice/:id/pay', to: 'invoice_user#pay'

  resources :invoice

end
