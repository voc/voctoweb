MediaBackend::Application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'admin/dashboard#index'

  # JSON API
  namespace :api do
    resources :conferences, :defaults => { :format => 'json' } do
      collection do
        post 'run_compile'
      end
    end
    resources :events, :defaults => { :format => 'json' } do
      collection do
        post 'download'
        post 'update_promoted'
      end
    end
    resources :recordings, :defaults => { :format => 'json' } do
      collection do
        post 'download'
      end
    end
    resources :news, :defaults => { :format => 'json' }
  end

  namespace :public do
    get :index, defaults: { format: 'json' }, only: :index
    resources :mirrors, only: [:index], defaults: { format: 'json' }
    resources :conferences, only: [:index, :show], defaults: { format: 'json' }
    resources :events, only: [:index, :show], defaults: { format: 'json' }
    resources :recordings, only: [:index, :show], defaults: { format: 'json' } do
      collection do
        post 'count'
      end
    end
  end

end
