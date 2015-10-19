MediaBackend::Application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  #root 'admin/dashboard#index'

  # VOC JSON API
  namespace :api do
    resources :conferences, :defaults => { :format => 'json' }
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

  # PUBLIC JSON API
  namespace :public do
    get :index, defaults: { format: 'json' }, only: :index
    get :oembed, only: :oembed
    resources :mirrors, only: [:index], defaults: { format: 'json' }
    resources :torrents, only: [:index], defaults: { format: 'text' }
    resources :conferences, only: [:index, :show], defaults: { format: 'json' }
    resources :events, only: [:index, :show], defaults: { format: 'json' }
    resources :recordings, only: [:index, :show], defaults: { format: 'json' } do
      collection do
        post 'count'
      end
    end
  end

  # FRONTEND
  scope module: 'frontend' do
    root to: 'home#index'
    if Rails.env.production?
      get '404', to: 'home#page_not_found'
    end
    get '/about', to: 'home#about'
    get '/search', to: 'home#search'
    get '/sitemap.xml', to: 'sitemap#index', defaults: { format: 'xml' }

    get '/events/:slug', to: 'events#show', as: :event, :constraints => { slug: %r'[^/]+' }
    get '/event/:slug/oembed', to: 'events#oembed', as: :oembed_event, :constraints => { slug: %r'[^/]+' }
    get '/event/:slug/download', to: 'events#download', as: :download_event, :constraints => { slug: %r'[^/]+' }

    get '/conferences/:acronym', to: 'conferences#show', as: :conference
    get '/browse', to: 'conferences#slug', as: :browse_start
    get '/browse/*slug', to: 'conferences#slug', as: :browse

    get '/tags', to: 'tags#index'
    get '/tags/:tag', to: 'tags#show', as: :tag

    get '/news.atom', to: 'news#index', defaults: { format: 'xml' }, as: :news
    get '/podcast-audio-only.xml', to: 'feeds#podcast_audio', defaults: { format: 'xml' }
    get '/podcast.xml', to: 'feeds#podcast', defaults: { format: 'xml' }
    get '/podcast-archive.xml', to: 'feeds#podcast_archive', defaults: { format: 'xml' }
    get '/updates.rdf', to: 'feeds#updates', defaults: { format: 'xml' }

    get '/podcast/:slug/:mime_type', to: 'feeds#podcast_folder', defaults: { format: 'xml' }, as: :podcast_folder_feed
  end

end
