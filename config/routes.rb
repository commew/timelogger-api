Rails.application.routes.draw do
  resources :accounts, only: [:index, :create]
  resources :task_groups, only: [:index], path: "task-groups"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
