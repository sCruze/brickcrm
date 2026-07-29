Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # --- Аутентификация ---
  resource :session, only: %i[new create destroy]

  # Внешний SSO. Роуты есть всегда, контроллер отвечает 404 при выключенном режиме.
  namespace :sso do
    get :start,    to: "sessions#start"
    get :callback, to: "sessions#callback"
  end

  # --- Входящий API синхронизации ---
  namespace :api do
    namespace :v1 do
      resources :events, only: :create
    end
  end

  # --- Разделы CRM (каркас) ---
  get "dashboard", to: "dashboard#index"
  resources :leads,   only: %i[index]
  resources :clients, only: %i[index]
  resources :tasks,   only: %i[index]
  get "calendar", to: "calendar#index"
  get "reports",  to: "reports#index"
  get "settings", to: "settings#index"

  root "dashboard#index"
end
