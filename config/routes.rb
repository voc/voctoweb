Rails.application.routes.draw do
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
        post 'update_promoted'
        post 'update_view_counts'
      end
    end
    resources :recordings, :defaults => { :format => 'json' }
    resources :news, :defaults => { :format => 'json' }
  end

  # PUBLIC JSON API
  namespace :public do
    get :index, path: '/', defaults: { format: 'json' }, only: :index
    get :oembed, only: :oembed
    resources :conferences, only: [:index, :show], defaults: { format: 'json' }
    resources :events, only: %i(index show), defaults: { format: 'json' }
    resources :recordings, only: %i(index show), defaults: { format: 'json' } do
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
    get '/search', to: 'search#index'
    get '/sitemap.xml', to: 'sitemap#index', defaults: { format: 'xml' }

    get '/v/:slug', to: 'events#show', as: :event, :constraints => { slug: %r'[^/]+' }
    get '/v/:slug/oembed', to: 'events#oembed', as: :oembed_event, :constraints => { slug: %r'[^/]+' }
    get '/v/:slug/download', to: 'events#download', as: :download_event, :constraints => { slug: %r'[^/]+' }

    get '/c/:acronym', to: 'conferences#show', as: :conference

    get '/b', to: 'conferences#browse', as: :browse_start
    get '/b/*slug', to: 'conferences#browse', as: :browse

    get '/recent', to: 'recent_changes#index'

    get '/tags', to: 'tags#index'
    get '/tags/:tag', to: 'tags#show', as: :tag

    get '/news.atom', to: 'news#index', defaults: { format: 'xml' }, as: :news
    get '/podcast-audio-only.xml', to: 'feeds#podcast_audio', defaults: { format: 'xml' }
    get '/podcast.xml', to: 'feeds#podcast', defaults: { format: 'xml' }
    get '/podcast-archive.xml', to: 'feeds#podcast_archive', defaults: { format: 'xml' }
    get '/updates.rdf', to: 'feeds#updates', defaults: { format: 'xml' }

    # legacy
    get '/podcast/:slug/:mime_type', to: 'feeds#podcast_folder', defaults: { format: 'xml' }, as: :old_podcast_folder_feed
    # new
    get '/c/:acronym/podcast/:mime_type.xml', to: 'feeds#podcast_folder', defaults: { format: 'xml' }, as: :podcast_folder_feed
  end

end
