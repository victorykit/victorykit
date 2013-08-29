require 'sidekiq/web'

Victorykit::Application.routes.draw do

  devise_for :users

  devise_scope :user do
    get    "/login" => "devise/sessions#new"
    delete "/logout" => "devise/sessions#destroy"
  end

  authenticate :user, lambda { |u| u.is_super_user || u.is_admin } do
    mount Sidekiq::Web => '/admin/sidekiq'
  end

  get "privacy/index"

  resources :users
  resources :bounces
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

  get 'contact', to: 'user_feedbacks#new', as: 'contact'

  namespace(:admin) do
    resources :petitions
    resources :users
    resources :members, only: [:index]

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
    resources :unsubscribes, only: [:index, :new, :create, :show] do
      member { get :stats }
      collection { post :export }
      collection { get :export }
    end

  end
  root :to => "site#index"
end
