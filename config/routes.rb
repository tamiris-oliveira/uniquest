Rails.application.routes.draw do
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

  resources :users, only: [ :create, :show, :update, :destroy, :index ]

  resources :groups do
    post "add_user", on: :member
  end

  resources :simulations do
    resources :questions
  end

  resources :questions, only: [ :show, :update, :destroy ] do
    resources :alternatives
  end

  resources :alternatives, only: [ :show, :update, :destroy ]

  resources :attempts do
    resources :answers, only: [ :index, :create ]
  end

  resources :answers, only: [ :show, :update, :destroy ] do
    resources :corrections
  end

  resources :notifications

  resources :reports
end
