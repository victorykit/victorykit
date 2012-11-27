Victorykit::Application.routes.draw do
  get "privacy/index"

  get "sessions/new"

  resources :users
  resources :members
  resources :bounces
  resources :sessions
  resources :whiplash_sessions
  resources :unsubscribes
  resources :pixel_tracking
  resources :incoming_mails
  resources :petitions do
    resources :signatures
    member { post 'again'; put 'send_email_preview' }
    collection { post 'send_email_preview' }
  end
  
  post 'social_tracking', to: 'social_tracking#create', as: 'social_tracking'
  post 'donation_tracking', to: 'donation_tracking#create', as: 'donation_tracking'
  get 'donation_tracking', to: 'donation_tracking#show', as: 'donation_tracking'
  resources :privacy
  resources :facebook_landing_page

  get 'login', to: 'users#new', as: 'login'
  get 'subscribe', to: 'members#new', as: 'subscribe'
  get 'unsubscribe', to: 'unsubscribes#new', as: 'subscribe'
  get 'logout', to: 'sessions#destroy', as: 'logout'
  get 'test_resque', to: 'signatures#test_resque', as:'test_resque'

  namespace(:admin) do
    resources :petitions
    resources :users

    resource :stats do
      member do
        get :metrics, :browser_usage
        get :index, to: "stats#metrics"
        get 'data/daily_browser_usage', to: "stats#daily_browser_usage"
        get 'data/email_response_rate', to: "stats#email_response_rate"
        get 'data/signature_activity', to: "stats#signature_activity"
        get 'data/opened_emails', to: "stats#opened_emails"
        get 'data/clicked_emails', to: "stats#clicked_emails"
        get 'data/nps_by_day', to: "stats#nps_by_day"
      end
    end

    get 'dashboard', to: 'dashboard#index'
    get 'funnel', to: 'dashboard#funnel', as: 'funnel'
    resources :experiments, only: [:index]
    resources :hottest
    resources :on_demand_email
    resources :heartbeat
  end
  root :to => "site#index"
end
