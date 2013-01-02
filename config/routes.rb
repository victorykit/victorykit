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
  resources :user_feedbacks
  resources :petitions do
    resources :signatures
    member { post 'again'; put 'send_email_preview' }
    collection { post 'send_email_preview' }
  end
  resources :privacy
  resources :facebook_landing_page

  post 'social_tracking', to: 'social_tracking#create', as: 'social_tracking'
  post 'donation_tracking', to: 'donation_tracking#create', as: 'donation_tracking'
  post 'paypal', to: 'donation_tracking#paypal', as: 'paypal'

  get 'login', to: 'users#new', as: 'login'
  get 'subscribe', to: 'members#new', as: 'subscribe'
  get 'unsubscribe', to: 'unsubscribes#new', as: 'subscribe'
  get 'logout', to: 'sessions#destroy', as: 'logout'
  get 'test_resque', to: 'signatures#test_resque', as:'test_resque'
  get 'contact', to: 'user_feedbacks#new', as: 'contact'

  namespace(:admin) do
    resources :petitions do
      collection { get 'new_dashboard' }
    end
    resources :users

    resource :stats do
      member do
        get :metrics, :browser_usage, :facebook, :emails
        get :index, to: "stats#metrics"
        get 'data/daily_browser_usage', to: "stats#daily_browser_usage"
        get 'data/daily_facebook_insight', to: "stats#daily_facebook_insight"
        get 'data/daily_facebook_conversion', to: "stats#daily_facebook_conversion"
        get 'data/email_response_rate', to: "stats#email_response_rate"
        get 'data/signature_activity', to: "stats#signature_activity"
        get 'data/opened_emails', to: "stats#opened_emails"
        get 'data/clicked_emails', to: "stats#clicked_emails"
        get 'data/nps_by_day', to: "stats#nps_by_day"
        get 'data/email_by_time_of_day', to: "stats#email_by_time_of_day"
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
