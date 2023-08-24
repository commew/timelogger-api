Rails.application.routes.draw do
  resources :accounts, only: [:index, :create]
  resources :task_groups, only: [:index], path: "task-groups"
  resources :tasks, only: [:create] do
    member do
      patch 'stop'
      patch 'complete'
    end
  end
  get 'tasks/recording', 'tasks#recording'
  get 'tasks/pending', 'tasks#pending'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
