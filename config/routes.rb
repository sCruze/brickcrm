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

  # --- Разделы CRM ---
  get "dashboard", to: "dashboard#index"

  resources :leads do
    member { patch :move }
  end
  resources :clients
  resources :tasks, except: :show do
    member { patch :toggle }
  end
  get "calendar", to: "calendar#index"
  get "reports",  to: "reports#index"
  namespace :settings do
    root to: "overview#index"
    resources :roles, except: :show
    resources :webhook_endpoints, except: :show
    resources :branches, except: :show
  end

  root "dashboard#index"
end
