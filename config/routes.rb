Rails.application.routes.draw do

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check
  get "attempts/index"
  get "attempts/show"
  get "attempts/create"
  get "attempts/update"
  get "attempts/destroy"
  get "corrections/index"
  get "corrections/create"
  get "corrections/show"
  get "corrections/update"
  get "corrections/destroy"
  get "answers/index"
  get "answers/create"
  get "answers/show"
  get "answers/update"
  get "answers/destroy"
  post "login", to: "authentication#login"
  get "/profile", to: "users#show"
  put "/profile", to: "users#update"
  delete "/profile", to: "users#destroy"

  resources :users, only: [ :index, :create ]

  resources :groups do
    post "add_user", on: :member
  end

  resources :simulations do
    member do
      get :groups
      get :questions
      put :assign_groups
      put :assign_questions
    end

    collection do
      get :with_attempts_answers
    end
  end

  resources :questions do
    resources :alternatives, only: [ :index, :create ]
  end

  resources :alternatives, only: [ :show, :update, :destroy ]

  resources :attempts do
    resources :answers, only: [:index, :create]
    post 'submit_answers', on: :member
  end
  
  resources :answers, only: [:show, :update, :destroy] do
    resources :corrections, only: [:index, :create]
  end
  
  resources :corrections, only: [:show, :update, :destroy]
  
  resources :notifications

  resources :reports, only: [] do
    collection do
      scope '/student' do
        get :performance_evolution
        get :subject_performance
      end

      scope '/teacher' do
        get 'group_summary/:group_id', to: 'reports#group_summary'
        get 'simulation_details/:simulation_id', to: 'reports#simulation_details'
        get :groups_comparison
      end
    end
  end

  resources :subjects

  resources :courses, only: [:index, :show, :create, :update] do
    resources :users, only: [:index]
  end
  
  resources :users, only: [:index, :show, :create, :update, :destroy]
  
  # Rotas para gerenciamento de aprovações
  resources :user_approvals, only: [:index] do
    member do
      post :approve
      post :reject
    end
    
    collection do
      post :request_teacher_role
    end
  end
end
