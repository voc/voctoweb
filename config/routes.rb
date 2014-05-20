MediaBackend::Application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'admin/dashboard#index'

  namespace :api do
    resources :conferences, :defaults => { :format => 'json' } do
      collection do
        post 'run_compile'
      end
    end
    resources :events, :defaults => { :format => 'json' } do
      collection do
        get 'download'
      end
    end
    resources :recordings, :defaults => { :format => 'json' } do
      collection do
        get 'download'
      end
    end
    resources :news, :defaults => { :format => 'json' }
  end

  namespace :public do
    resources :conferences, only: [:index, :show], defaults: { format: 'json' }
    resources :events, only: [:index, :show], defaults: { format: 'json' }
    resources :recordings, only: [:index, :show], defaults: { format: 'json' }
  end

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
