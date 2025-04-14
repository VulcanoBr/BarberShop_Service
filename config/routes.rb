Rails.application.routes.draw do

  devise_for :admin_users, controllers: {
    sessions: 'admin/sessions', # Usa o SessionsController no namespace :admin
  }

  namespace :admin do
    get 'dashboard', to: 'dashboard#index', as: 'dashboard'
    resources :services
    resources :employees
    resources :appointments, only: [:index, :show, :edit, :new, :update, :destroy] # Listar, Ver, Deletar Agendamentos
    root to: 'appointments#index' # Raiz da área admin
  end

  # Rota principal para agendamento
  get 'agendar', to: 'appointments#new', as: 'new_appointment'
  resources :appointments, only: [:create, :show]
  get 'list_services', to: 'home#list_services', as: 'list_services'

  # Rota para atualizar horários (será usado pelo Turbo Frame/Stimulus)
  # Ex: /appointments/available_slots?date=YYYY-MM-DD
  # (Vamos integrar isso na action 'new' por enquanto para simplicidade)

  # Página inicial (pode redirecionar para agendamento ou ter uma landing page)
  root 'home#index'

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
end
