Rails.application.routes.draw do
  post 'accounts', to: 'accounts#post'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
