Victorykit::Application.routes.draw do
  mount FacebookShareWidget::Engine => "/widget"
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
  end
  resources :social_tracking
  resources :privacy

  get 'login', to: 'users#new', as: 'login'
  get 'subscribe', to: 'members#new', as: 'subscribe'
  get 'unsubscribe', to: 'unsubscribes#new', as: 'subscribe'
  get 'logout', to: 'sessions#destroy', as: 'logout'

  post 'petitions/send_email_preview', to: 'petitions#send_email_preview', as: 'send_email_preview'
  put 'petitions/:id/send_email_preview', to: 'petitions#send_email_preview', as: 'send_email_preview'

  namespace(:admin) do
    resources :petitions 
    resources :users
    resources :experiments
    resources :hottest
    resources :on_demand_email
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
  root :to => "site#index"
end
